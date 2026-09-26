import { defineStore } from 'pinia'
import { ref } from 'vue'
import { exec } from 'kernelsu'
import * as KernelSU from '@/helpers/KernelSU'

async function getConfigDir() {
  if (await KernelSU.fileExists('/data/adb/.config/zcore/current_profile')) {
    return '/data/adb/.config/zcore'
  }
  if (await KernelSU.fileExists('/data/adb/.config/encore/current_profile')) {
    return '/data/adb/.config/encore'
  }
  if (await KernelSU.fileExists('/data/adb/.config/zcore')) {
    return '/data/adb/.config/zcore'
  }
  return '/data/adb/.config/encore'
}

async function getModDir() {
  if (await KernelSU.fileExists('/data/adb/modules/zcore/module.prop')) {
    return '/data/adb/modules/zcore'
  }
  if (await KernelSU.fileExists('/data/adb/modules/encore/module.prop')) {
    return '/data/adb/modules/encore'
  }
  return '/data/adb/modules/zcore'
}

export const useHomeStore = defineStore('home', () => {
  const daemonPidRaw = ref('')
  const moduleVersion = ref('')
  const currentProfileRaw = ref('')
  const kernelVersion = ref('')
  const chipsetName = ref('')
  const androidSDK = ref('')
  const daemonStatusRaw = ref('loading') // 'loading', 'running', 'stopped', 'error'
  const daemonError = ref('')
  const logoImage = ref('/encore_sleeping.avif')
  const isInitialized = ref(false)

  let profileInterval = null
  let daemonInterval = null

  // Actions
  async function initializeData() {
    if (isInitialized.value) return

    await Promise.all([
      getServiceState(),
      getAndroidSDK(),
      getModuleVersion(),
      getCurrentProfile(),
      getKernelVersion(),
      getChipset(),
    ])

    startProfileMonitoring()
    startDaemonMonitoring()
    isInitialized.value = true
  }

  function startProfileMonitoring() {
    stopProfileMonitoring()

    profileInterval = setInterval(() => {
      getCurrentProfile()
    }, 1000)
  }

  function stopProfileMonitoring() {
    if (profileInterval) {
      clearInterval(profileInterval)
      profileInterval = null
    }
  }

  function startDaemonMonitoring() {
    stopDaemonMonitoring()

    daemonInterval = setInterval(() => {
      getServiceState()
    }, 1000)
  }

  function stopDaemonMonitoring() {
    if (daemonInterval) {
      clearInterval(daemonInterval)
      daemonInterval = null
    }
  }

  async function getServiceState() {
    try {
      if (!KernelSU.isKSUWebUI()) {
        throw new Error('Not running on KSU WebUI')
      }

      let pid = ''
      let res = await exec('/system/bin/toybox pidof zcored')
      if (res.errno === 0 && res.stdout.trim()) {
        pid = res.stdout.trim().split(' ')[0]
      } else {
        res = await exec('/system/bin/toybox pidof encored')
        if (res.errno === 0 && res.stdout.trim()) {
          pid = res.stdout.trim().split(' ')[0]
        }
      }

      if (pid) {
        daemonPidRaw.value = pid
        daemonStatusRaw.value = 'running'
        daemonError.value = ''
        logoImage.value = '/encore_happy.avif'
        return
      }

      setDaemonStopped()
      return
    } catch (error) {
      setDaemonError(error.message)
    }
  }

  function setDaemonStopped() {
    daemonStatusRaw.value = 'stopped'
    daemonPidRaw.value = ''
    daemonError.value = ''
    logoImage.value = '/encore_sleeping.avif'
  }

  function setDaemonError(message) {
    daemonStatusRaw.value = 'error'
    daemonError.value = message
    logoImage.value = '/encore_sleeping.avif'
  }

  async function getAndroidSDK() {
    try {
      if (!KernelSU.isKSUWebUI()) {
        throw new Error('Not running on KSU WebUI')
      }

      const { stdout } = await exec('getprop ro.build.version.sdk')
      androidSDK.value = stdout.trim()
    } catch (error) {
      androidSDK.value = 'unknown'
    }
  }

  async function getModuleVersion() {
    try {
      const dir = await getModDir()
      const propPath = `${dir}/module.prop`
      const content = await KernelSU.readFile(propPath)
      const match = content.match(/^version=(.*)$/m)
      moduleVersion.value = match ? match[1].trim() : 'unknown'
    } catch (error) {
      moduleVersion.value = 'unknown'
    }
  }

  async function getCurrentProfile() {
    try {
      const dir = await getConfigDir()
      const output = await KernelSU.readFile(`${dir}/current_profile`)
      currentProfileRaw.value = getProfileKey(output.trim())
    } catch (error) {
      currentProfileRaw.value = 'unknown'
    }
  }

  function getProfileKey(profileCode) {
    const profileMap = {
      0: 'initializing',
      1: 'performance',
      2: 'balanced',
      3: 'powersave',
    }
    return profileMap[profileCode] || 'unknown'
  }

  async function getKernelVersion() {
    try {
      if (!KernelSU.isKSUWebUI()) {
        throw new Error('Not running on KSU WebUI')
      }

      const { stdout } = await exec('uname -r -m')
      kernelVersion.value = stdout.trim()
    } catch (error) {
      kernelVersion.value = 'unknown'
    }
  }

  async function getChipset() {
    try {
      if (!KernelSU.isKSUWebUI()) {
        throw new Error('Not running on KSU WebUI')
      }

      const { stdout } = await exec('getprop ro.board.platform')
      const chipset = stdout.trim()
      const brand = await getChipsetBrand()

      chipsetName.value = `${brand} ${chipset}`
    } catch (error) {
      chipsetName.value = 'unknown'
    }
  }

  async function getChipsetBrand() {
    try {
      const soc = await KernelSU.readFile(`${configPath}/soc_recognition`)
      const brands = {
        1: 'MediaTek',
        2: 'Snapdragon',
        3: 'Exynos',
        4: 'Unisoc',
        5: 'Tensor',
        6: 'Intel',
        7: 'Tegra',
        8: 'Kirin',
      }
      return brands[soc] || ''
    } catch (error) {
      return ''
    }
  }

  return {
    // Raw state
    daemonPidRaw,
    moduleVersion,
    currentProfileRaw,
    kernelVersion,
    chipsetName,
    androidSDK,
    daemonStatusRaw,
    daemonError,
    logoImage,
    isInitialized,

    // Actions
    initializeData,
    stopProfileMonitoring,
    stopDaemonMonitoring,
    getServiceState,
    getAndroidSDK,
    getModuleVersion,
    getCurrentProfile,
    getKernelVersion,
    getChipset,
  }
})
