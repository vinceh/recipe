<template>
  <span
    v-if="hasChanged"
    class="nutrition-sparkle"
    @mouseenter="handleMouseEnter"
    @mouseleave="handleMouseLeave"
    @touchstart.prevent="handleTouchStart"
  >
    <img
      ref="sparkleRef"
      src="@/assets/images/sparkles-red.svg"
      alt=""
      class="nutrition-sparkle__icon"
    />
    <Teleport to="body">
      <Transition name="tooltip">
        <div
          v-if="showTooltip"
          class="nutrition-sparkle__tooltip"
          :style="tooltipStyle"
        >
          <span class="nutrition-sparkle__tooltip-label">{{ t('recipe.adjust.adjustedFrom') }}</span>
          <span class="nutrition-sparkle__tooltip-original">{{ formattedOriginal }}</span>
        </div>
      </Transition>
    </Teleport>
  </span>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, onUnmounted } from 'vue'
import { useI18n } from 'vue-i18n'

const { t } = useI18n({ useScope: 'global' })

interface Props {
  currentValue: number | undefined | null
  originalValue: number | undefined | null
  suffix?: string
}

const props = withDefaults(defineProps<Props>(), {
  suffix: ''
})

const showTooltip = ref(false)
const sparkleRef = ref<HTMLImageElement | null>(null)
const tooltipPosition = ref({ top: 0, left: 0 })

const hasChanged = computed(() => {
  if (props.originalValue === undefined || props.originalValue === null) return false
  if (props.currentValue === undefined || props.currentValue === null) return false
  return props.currentValue !== props.originalValue
})

const formattedOriginal = computed(() => {
  if (props.originalValue === null || props.originalValue === undefined) return ''
  return `${props.originalValue}${props.suffix}`
})

const tooltipStyle = computed(() => ({
  top: `${tooltipPosition.value.top}px`,
  left: `${tooltipPosition.value.left}px`,
}))

function handleMouseEnter() {
  if (sparkleRef.value) {
    const rect = sparkleRef.value.getBoundingClientRect()
    tooltipPosition.value = {
      top: rect.top - 8,
      left: rect.left + rect.width / 2,
    }
  }
  showTooltip.value = true
}

function handleMouseLeave() {
  showTooltip.value = false
}

function handleTouchStart() {
  if (sparkleRef.value) {
    const rect = sparkleRef.value.getBoundingClientRect()
    tooltipPosition.value = {
      top: rect.top - 8,
      left: rect.left + rect.width / 2,
    }
  }
  showTooltip.value = !showTooltip.value
}

function handleScroll() {
  if (showTooltip.value) {
    showTooltip.value = false
  }
}

function handleGlobalTouch(e: TouchEvent) {
  if (showTooltip.value && sparkleRef.value && !sparkleRef.value.contains(e.target as Node)) {
    showTooltip.value = false
  }
}

onMounted(() => {
  window.addEventListener('scroll', handleScroll, { passive: true })
  document.addEventListener('touchstart', handleGlobalTouch, { passive: true })
})

onUnmounted(() => {
  window.removeEventListener('scroll', handleScroll)
  document.removeEventListener('touchstart', handleGlobalTouch)
})
</script>

<style scoped>
.nutrition-sparkle {
  display: block;
  text-align: center;
  margin-top: 4px;
  cursor: help;
}

.nutrition-sparkle__icon {
  width: 16px;
  height: 16px;
  opacity: 0.85;
}
</style>

<style>
.nutrition-sparkle__tooltip {
  position: fixed;
  transform: translateX(-50%) translateY(-100%);
  background: var(--color-gray-800);
  color: var(--color-text-inverse);
  padding: 8px 12px;
  border-radius: var(--border-radius-sm);
  font-size: var(--font-size-sm);
  white-space: nowrap;
  z-index: var(--z-index-tooltip);
  box-shadow: var(--shadow-lg);
  pointer-events: none;
}

.nutrition-sparkle__tooltip::after {
  content: '';
  position: absolute;
  top: 100%;
  left: 50%;
  transform: translateX(-50%);
  border: 6px solid transparent;
  border-top-color: var(--color-gray-800);
}

.nutrition-sparkle__tooltip-label {
  color: var(--color-text-tertiary);
  margin-right: 6px;
}

.nutrition-sparkle__tooltip-original {
  opacity: 0.9;
}
</style>
