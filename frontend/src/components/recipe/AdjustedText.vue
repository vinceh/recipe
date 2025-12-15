<template>
  <span
    class="adjusted-text"
    :class="{ 'adjusted-text--changed': shouldHighlight }"
  >
    <slot></slot>
    <span
      v-if="shouldHighlight"
      class="adjusted-text__sparkle-wrapper"
      @mouseenter="handleMouseEnter"
      @mouseleave="handleMouseLeave"
    >
      <img
        ref="sparkleRef"
        src="@/assets/images/sparkles-red.svg"
        alt=""
        class="adjusted-text__sparkle"
      />
    </span>
    <Teleport to="body">
      <Transition name="tooltip">
        <div
          v-if="showTooltip && shouldHighlight"
          class="adjusted-text__tooltip"
          :style="tooltipStyle"
        >
          <template v-if="isNewlyAdded">
            <span class="adjusted-text__tooltip-label">{{ t('recipe.adjust.newlyAdded') }}</span>
          </template>
          <template v-else>
            <span class="adjusted-text__tooltip-label">{{ t('recipe.adjust.adjustedFrom') }}</span>
            <span class="adjusted-text__tooltip-original">{{ originalValue }}</span>
          </template>
        </div>
      </Transition>
    </Teleport>
  </span>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import { useI18n } from 'vue-i18n'

const { t } = useI18n()

interface Props {
  currentValue: string | number | undefined | null
  originalValue: string | number | undefined | null
  isAiAdjusted?: boolean
}

const props = withDefaults(defineProps<Props>(), {
  isAiAdjusted: false
})

const showTooltip = ref(false)
const sparkleRef = ref<HTMLImageElement | null>(null)
const tooltipPosition = ref({ top: 0, left: 0 })

const isNewlyAdded = computed(() => {
  if (!props.isAiAdjusted) return false
  if (props.currentValue === undefined || props.currentValue === null) return false
  return props.originalValue === undefined || props.originalValue === null
})

const hasChanged = computed(() => {
  if (props.originalValue === undefined || props.originalValue === null) return false
  if (props.currentValue === undefined || props.currentValue === null) return false
  return String(props.currentValue) !== String(props.originalValue)
})

const shouldHighlight = computed(() => {
  return hasChanged.value || isNewlyAdded.value
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
</script>

<style scoped>
.adjusted-text {
  position: relative;
  display: inline;
}

.adjusted-text--changed {
  text-decoration: underline;
  text-decoration-style: dotted;
  text-decoration-color: rgba(194, 84, 80, 0.4);
  text-underline-offset: 3px;
}

.adjusted-text__sparkle-wrapper {
  display: inline;
  cursor: help;
}

.adjusted-text__sparkle {
  width: 18px;
  height: 18px;
  margin-left: 4px;
  vertical-align: middle;
  opacity: 0.85;
}

.adjusted-text__tooltip-label {
  color: #aaa;
  margin-right: 6px;
}

.adjusted-text__tooltip-original {
  opacity: 0.9;
}
</style>

<style>
/* Global styles for teleported tooltip */
.adjusted-text__tooltip {
  position: fixed;
  transform: translateX(-50%) translateY(-100%);
  background: #333;
  color: white;
  padding: 8px 12px;
  border-radius: 4px;
  font-size: 13px;
  white-space: nowrap;
  z-index: 10000;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.2);
  pointer-events: none;
}

.adjusted-text__tooltip::after {
  content: '';
  position: absolute;
  top: 100%;
  left: 50%;
  transform: translateX(-50%);
  border: 6px solid transparent;
  border-top-color: #333;
}

/* Tooltip animation */
.tooltip-enter-active,
.tooltip-leave-active {
  transition: opacity 0.15s, transform 0.15s;
}

.tooltip-enter-from,
.tooltip-leave-to {
  opacity: 0;
  transform: translateX(-50%) translateY(calc(-100% + 4px));
}
</style>
