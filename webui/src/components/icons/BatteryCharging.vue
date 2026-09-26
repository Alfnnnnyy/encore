<template>
  <svg
    xmlns="http://www.w3.org/2000/svg"
    :width="size"
    :height="size"
    viewBox="0 0 24 24"
    :fill="color"
  >
    <path
      d="M12 20H4V6H12V20M12 2H4C2.89 2 2 2.89 2 4V22C2 23.11 2.89 24 4 24H12C13.11 24 14 23.11 14 22V4C14 2.89 13.11 2 12 2M23 10H20V4L15 14H18V20L23 10Z"
    />
  </svg>
</template>

<script setup>
defineProps({
  size: {
    type: [String, Number],
    default: 24,
  },
  color: {
    type: String,
    default: 'currentColor',
  },
})
</script>
