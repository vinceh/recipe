<template>
  <span
    class="adjusted-line"
    :class="{ 'adjusted-line--changed': shouldHighlight }"
  >
    <slot></slot>
    <span
      v-if="shouldHighlight"
      class="adjusted-line__sparkle-wrapper"
      @mouseenter="handleMouseEnter"
      @mouseleave="handleMouseLeave"
    >
      <img
        ref="sparkleRef"
        src="@/assets/images/sparkles-red.svg"
        alt=""
        class="adjusted-line__sparkle"
      />
    </span>
    <Teleport to="body">
      <Transition name="tooltip">
        <div
          v-if="showTooltip && shouldHighlight"
          class="adjusted-line__tooltip"
          :style="tooltipStyle"
        >
          <template v-if="isNewlyAdded">
            <span class="adjusted-line__tooltip-label">{{ t('recipe.adjust.newlyAdded') }}</span>
          </template>
          <template v-else>
            <div v-for="(change, index) in changes" :key="index" class="adjusted-line__tooltip-row">
              <span class="adjusted-line__tooltip-label">{{ change.label }}:</span>
              <span class="adjusted-line__tooltip-original">{{ change.from }}</span>
              <span class="adjusted-line__tooltip-arrow">→</span>
              <span class="adjusted-line__tooltip-new">{{ change.to }}</span>
            </div>
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

interface IngredientValues {
  displayAmount?: string | null
  name?: string | null
  preparation?: string | null
}

interface Props {
  current: IngredientValues | null
  original: IngredientValues | null
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
  if (!props.current) return false
  return props.original === null || props.original === undefined
})

interface Change {
  label: string
  from: string
  to: string
}

const changes = computed<Change[]>(() => {
  if (!props.current || !props.original) return []

  const result: Change[] = []

  if (props.current.displayAmount !== props.original.displayAmount &&
      props.current.displayAmount && props.original.displayAmount) {
    result.push({
      label: t('forms.recipe.ingredientAmount'),
      from: props.original.displayAmount,
      to: props.current.displayAmount
    })
  }

  if (props.current.name !== props.original.name &&
      props.current.name && props.original.name) {
    result.push({
      label: t('forms.recipe.ingredientName'),
      from: props.original.name,
      to: props.current.name
    })
  }

  if (props.current.preparation !== props.original.preparation) {
    if (props.current.preparation && props.original.preparation) {
      result.push({
        label: t('forms.recipe.ingredientNotes'),
        from: props.original.preparation,
        to: props.current.preparation
      })
    } else if (props.current.preparation && !props.original.preparation) {
      result.push({
        label: t('forms.recipe.ingredientNotes'),
        from: '—',
        to: props.current.preparation
      })
    }
  }

  return result
})

const hasAnyChange = computed(() => {
  if (!props.current || !props.original) return false

  const amountChanged = props.current.displayAmount !== props.original.displayAmount
  const nameChanged = props.current.name !== props.original.name
  const prepChanged = props.current.preparation !== props.original.preparation

  return amountChanged || nameChanged || prepChanged
})

const shouldHighlight = computed(() => {
  return isNewlyAdded.value || hasAnyChange.value
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
.adjusted-line {
  position: relative;
  display: inline;
}

.adjusted-line--changed {
  text-decoration: underline;
  text-decoration-style: dotted;
  text-decoration-color: rgba(194, 84, 80, 0.4);
  text-underline-offset: 3px;
}

.adjusted-line__sparkle-wrapper {
  display: inline;
  cursor: help;
}

.adjusted-line__sparkle {
  width: 18px;
  height: 18px;
  margin-left: 4px;
  vertical-align: middle;
  opacity: 0.85;
}
</style>

<style>
/* Global styles for teleported tooltip */
.adjusted-line__tooltip {
  position: fixed;
  transform: translateX(-50%) translateY(-100%);
  background: #333;
  color: white;
  padding: 8px 12px;
  border-radius: 4px;
  font-size: 13px;
  z-index: 10000;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.2);
  pointer-events: none;
}

.adjusted-line__tooltip::after {
  content: '';
  position: absolute;
  top: 100%;
  left: 50%;
  transform: translateX(-50%);
  border: 6px solid transparent;
  border-top-color: #333;
}

.adjusted-line__tooltip-row {
  display: flex;
  align-items: center;
  gap: 6px;
  white-space: nowrap;
}

.adjusted-line__tooltip-row + .adjusted-line__tooltip-row {
  margin-top: 4px;
}

.adjusted-line__tooltip-label {
  color: #aaa;
}

.adjusted-line__tooltip-original {
  text-decoration: line-through;
  opacity: 0.7;
}

.adjusted-line__tooltip-arrow {
  color: #888;
}

.adjusted-line__tooltip-new {
  opacity: 0.9;
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
