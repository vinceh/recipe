<template>
  <Teleport to="body">
    <Transition name="modal">
      <div v-if="isOpen" class="modal-backdrop" @click="handleBackdropClick">
        <div class="modal-content confirm-dialog" @click.stop role="dialog" aria-modal="true">
          <div class="modal-header">
            <h3 class="modal-title">{{ title }}</h3>
          </div>

          <div class="modal-body">
            <p class="confirm-dialog__message">{{ message }}</p>
            <slot></slot>
          </div>

          <div class="modal-footer">
            <button
              class="btn btn-outline"
              @click="handleCancel"
              :disabled="loading"
            >
              {{ cancelText }}
            </button>
            <button
              :class="confirmButtonClass"
              @click="handleConfirm"
              :disabled="loading"
            >
              <LoadingSpinner v-if="loading" size="sm" />
              <span v-else>{{ confirmText }}</span>
            </button>
          </div>
        </div>
      </div>
    </Transition>
  </Teleport>
</template>

<script setup lang="ts">
import { computed, onMounted, onUnmounted } from 'vue'
import LoadingSpinner from './LoadingSpinner.vue'

interface Props {
  /**
   * Whether the dialog is open
   */
  isOpen: boolean

  /**
   * Dialog title
   * @default 'Confirm'
   */
  title?: string

  /**
   * Confirmation message
   */
  message: string

  /**
   * Confirm button text
   * @default 'Confirm'
   */
  confirmText?: string

  /**
   * Cancel button text
   * @default 'Cancel'
   */
  cancelText?: string

  /**
   * Severity level (affects confirm button style)
   * @default 'primary'
   */
  severity?: 'primary' | 'error' | 'warning' | 'success'

  /**
   * Whether confirm action is loading
   * @default false
   */
  loading?: boolean

  /**
   * Whether clicking backdrop closes dialog
   * @default true
   */
  closeOnBackdrop?: boolean
}

const props = withDefaults(defineProps<Props>(), {
  title: 'Confirm',
  confirmText: 'Confirm',
  cancelText: 'Cancel',
  severity: 'primary',
  loading: false,
  closeOnBackdrop: true
})

interface Emits {
  (e: 'confirm'): void
  (e: 'cancel'): void
  (e: 'update:isOpen', value: boolean): void
}

const emit = defineEmits<Emits>()

const confirmButtonClass = computed(() => ({
  btn: true,
  'btn-primary': props.severity === 'primary',
  'btn-error': props.severity === 'error',
  'btn-warning': props.severity === 'warning',
  'btn-success': props.severity === 'success'
}))

const handleConfirm = () => {
  emit('confirm')
}

const handleCancel = () => {
  emit('cancel')
  emit('update:isOpen', false)
}

const handleBackdropClick = () => {
  if (props.closeOnBackdrop && !props.loading) {
    handleCancel()
  }
}

// Handle ESC key to close dialog
const handleEscape = (event: KeyboardEvent) => {
  if (event.key === 'Escape' && props.isOpen && !props.loading) {
    handleCancel()
  }
}

onMounted(() => {
  document.addEventListener('keydown', handleEscape)
})

onUnmounted(() => {
  document.removeEventListener('keydown', handleEscape)
})
</script>

<style scoped>
.confirm-dialog {
  max-width: 500px;
}

.confirm-dialog__message {
  font-size: var(--font-size-base);
  color: var(--color-text);
  line-height: var(--line-height-relaxed);
  margin: 0;
}

/* Modal animations */
.modal-enter-active,
.modal-leave-active {
  transition: opacity var(--transition-base);
}

.modal-enter-from,
.modal-leave-to {
  opacity: 0;
}

.modal-enter-active .modal-content,
.modal-leave-active .modal-content {
  transition: transform var(--transition-base);
}

.modal-enter-from .modal-content,
.modal-leave-to .modal-content {
  transform: scale(0.95);
}
</style>

<style>
/* Global modal styles are defined in components.css */
</style>
