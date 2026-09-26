import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import * as KernelSU from '@/helpers/KernelSU'

export const useGamesStore = defineStore('games', () => {
  const userApps = ref([])
  const searchQuery = ref('')
  const isLoading = ref(false)
  const gamelistConfig = ref({})
  const isBypassSupported = ref(false)

  async function checkBypassSupport() {
    try {
      const qcomNodes = [
        '/sys/devices/platform/soc/soc:qcom,pmic_glink/soc:qcom,pmic_glink:qcom,battery_charger/power_supply/battery/charge_control_limit',
        '/sys/devices/platform/soc/soc:qcom,pmic_glink/soc:qcom,pmic_glink:qcom,battery_charger/power_supply/battery/constant_charge_current',
        '/sys/class/qcom-battery/input_suspend',
      ]
      const checks = await Promise.all(qcomNodes.map((p) => KernelSU.fileExists(p)))
      isBypassSupported.value = checks.every(Boolean)
    } catch {
      isBypassSupported.value = false
    }
    return isBypassSupported.value
  }

  const isAppEnabled = (packageName) => packageName in gamelistConfig.value

  // Computed property for filtered apps
  const filteredApps = computed(() => {
    let apps = userApps.value

    if (searchQuery.value.trim()) {
      const q = searchQuery.value.toLowerCase()
      apps = apps.filter(
        (a) => a.appName?.toLowerCase().includes(q) || a.packageName?.toLowerCase().includes(q),
      )
    }

    const [enabled, disabled] = [
      apps.filter((a) => isAppEnabled(a.packageName)),
      apps.filter((a) => !isAppEnabled(a.packageName)),
    ]

    const sortByName = (a, b) =>
      (a.appName || a.packageName).localeCompare(b.appName || b.packageName)

    return [...enabled.sort(sortByName), ...disabled.sort(sortByName)]
  })

  async function getConfigPath() {
    if (await KernelSU.fileExists('/data/adb/.config/zcore/gamelist.json')) {
      return '/data/adb/.config/zcore/gamelist.json'
    }
    if (await KernelSU.fileExists('/data/adb/.config/encore/gamelist.json')) {
      return '/data/adb/.config/encore/gamelist.json'
    }
    return '/data/adb/.config/zcore/gamelist.json'
  }

  let activeConfigPath = '/data/adb/.config/zcore/gamelist.json'

  async function loadGamelistConfig() {
    try {
      activeConfigPath = await getConfigPath()
      if (await KernelSU.fileExists(activeConfigPath)) {
        const content = await KernelSU.readFile(activeConfigPath)
        gamelistConfig.value = JSON.parse(content)
        console.log('Gamelist config loaded successfully')
        return gamelistConfig.value
      } else {
        gamelistConfig.value = {}
        return gamelistConfig.value
      }
    } catch (e) {
      console.error('Failed to load gamelist config:', e)
      gamelistConfig.value = {}
      throw e
    }
  }

  async function saveGamelistConfig() {
    try {
      const configString = JSON.stringify(gamelistConfig.value, null, 2)
      await KernelSU.writeFile(activeConfigPath, configString)
      console.log('Gamelist config saved successfully')
      return true
    } catch (e) {
      console.error('Failed to save gamelist config:', e)
      throw e
    }
  }

  async function updateAppConfig(packageName, config) {
    if (!packageName) {
      throw new Error('Package name is required')
    }

    const currentConfig = { ...gamelistConfig.value }

    if (config) {
      currentConfig[packageName] = {
        lite_mode: !!config.lite_mode,
        enable_dnd: !!config.enable_dnd,
      }
    } else {
      delete currentConfig[packageName]
    }

    gamelistConfig.value = currentConfig

    const appIndex = userApps.value.findIndex((a) => a.packageName === packageName)
    if (appIndex !== -1) {
      userApps.value[appIndex].isEnabled = !!config
    }

    await saveGamelistConfig()

    return currentConfig[packageName] || null
  }

  async function toggleAppEnabled(packageName, enabled) {
    const currentConfig = gamelistConfig.value[packageName] || {}

    if (enabled) {
      return await updateAppConfig(packageName, {
        lite_mode: currentConfig.lite_mode || false,
        enable_dnd: currentConfig.enable_dnd || false,
        enable_bypass_charging: currentConfig.enable_bypass_charging || false,
      })
    } else {
      return await updateAppConfig(packageName, null)
    }
  }

  async function updateAppSetting(packageName, setting, value) {
    const currentConfig = gamelistConfig.value[packageName] || {}

    return await updateAppConfig(packageName, {
      ...currentConfig,
      [setting]: value,
    })
  }

  async function loadUserApps() {
    if (userApps.value.length > 0) {
      return
    }

    isLoading.value = true

    try {
      const pkgs = await KernelSU.listApps()
      const chunk = 15
      const loaded = []

      for (let i = 0; i < pkgs.length; i += chunk) {
        const slice = pkgs.slice(i, i + chunk)

        try {
          const [infos, icons] = await Promise.allSettled([
            KernelSU.getBatchAppLabel(slice),
            KernelSU.getBatchAppIcons(slice, 100),
          ])

          const appInfos =
            infos.status === 'fulfilled'
              ? infos.value
              : slice.map((pkg) => ({ packageName: pkg, appName: pkg }))

          const appIcons =
            icons.status === 'fulfilled'
              ? icons.value
              : slice.map((pkg) => ({ packageName: pkg, icon: '' }))

          loaded.push(
            ...appInfos.map((info) => {
              const matchingIcon = appIcons.find((icon) => icon.packageName === info.packageName)
              const iconUrl = matchingIcon?.icon || '/fallback_app_icon.avif'

              if (!matchingIcon?.icon) {
                console.warn(`[loadUserApps] No icon for ${info.packageName}, using fallback`)
              }

              return {
                packageName: info.packageName,
                appName: info.appName,
                icon: iconUrl,
                isEnabled: isAppEnabled(info.packageName),
              }
            }),
          )
          userApps.value = loaded
          await new Promise((r) => setTimeout(r, 10))
        } catch (batchError) {
          console.error(
            '[loadUserApps] Batch processing failed, loading apps with minimal info:',
            batchError,
          )

          const fallbackApps = slice.map((pkg) => ({
            packageName: pkg,
            appName: pkg,
            icon: '/fallback_app_icon.avif',
            isEnabled: isAppEnabled(pkg),
          }))

          loaded.push(...fallbackApps)
          userApps.value = loaded
        }
      }
    } catch (e) {
      console.error('[loadUserApps] Failed to fetch app info:', e)
      try {
        const pkgs = await KernelSU.listApps()
        userApps.value = pkgs.map((packageName) => ({
          packageName,
          appName: packageName,
          icon: '/fallback_app_icon.avif',
          isEnabled: isAppEnabled(packageName),
        }))
      } catch (finalError) {
        console.error('[loadUserApps] Failed completely:', finalError)
        userApps.value = []
      }
    } finally {
      isLoading.value = false
    }
  }

  async function refreshFromSettings() {
    await loadGamelistConfig()
    const updatedApps = [...userApps.value]
    updatedApps.forEach((app) => {
      app.isEnabled = isAppEnabled(app.packageName)
    })
    userApps.value = updatedApps
  }

  async function initializeData() {
    try {
      await loadGamelistConfig()
    } catch (e) {
      console.error('Failed to load gamelist:', e)
    }
    await loadUserApps()
  }

  return {
    userApps,
    filteredApps,
    searchQuery,
    isLoading,
    gamelistConfig,
    isAppEnabled,

    // Config management methods
    loadGamelistConfig,
    saveGamelistConfig,
    updateAppConfig,
    toggleAppEnabled,
    updateAppSetting,

    // App management methods
    loadUserApps,
    initializeData,
    refreshFromSettings,
    isBypassSupported,
    checkBypassSupport,
  }
})
