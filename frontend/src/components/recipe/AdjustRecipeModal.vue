<template>
  <Teleport to="body">
    <Transition name="modal">
      <div v-if="show" class="modal-backdrop" @click="handleBackdropClick">
        <div class="modal-content adjust-recipe-modal" @click.stop role="dialog" aria-modal="true">
          <div class="modal-header">
            <h3 class="modal-title">{{ $t('recipe.adjust.title') }}</h3>
          </div>

          <div class="modal-body">
            <p class="adjust-recipe-modal__description">
              {{ $t('recipe.adjust.description') }}
            </p>

            <div v-if="error" class="adjust-recipe-modal__error">
              {{ error }}
            </div>

            <textarea
              v-model="prompt"
              class="adjust-recipe-modal__textarea"
              :placeholder="$t('recipe.adjust.placeholder')"
              :disabled="loading"
              rows="8"
            ></textarea>
          </div>

          <div class="modal-footer">
            <button
              class="btn btn-outline"
              @click="handleCancel"
              :disabled="loading"
            >
              {{ $t('common.buttons.cancel') }}
            </button>
            <button
              class="btn adjust-recipe-modal__submit-btn"
              @click="handleAdjust"
              :disabled="loading || !prompt.trim()"
            >
              <span>{{ loading ? $t('recipe.adjust.adjusting') : $t('recipe.adjust.submit') }}</span>
              <img src="@/assets/images/sparkles.svg" alt="" class="sparkle-icon" />
            </button>
          </div>
        </div>
      </div>
    </Transition>
  </Teleport>
</template>

<script setup lang="ts">
import { ref, onMounted, onUnmounted } from 'vue'
import { useI18n } from 'vue-i18n'
import type { RecipeDetail } from '@/services/types'
import { recipeApi } from '@/services/recipeApi'

const { t } = useI18n()

interface Props {
  show: boolean
  recipe: RecipeDetail | null
}

const props = defineProps<Props>()

interface Emits {
  (e: 'close'): void
  (e: 'adjusted', recipe: RecipeDetail): void
}

const emit = defineEmits<Emits>()

const prompt = ref('')
const loading = ref(false)
const error = ref('')

async function handleAdjust() {
  if (!props.recipe || !prompt.value.trim()) return

  loading.value = true
  error.value = ''

  try {
    const response = await recipeApi.adjustRecipe(props.recipe, prompt.value.trim())
    if (response.success && response.data.recipe) {
      emit('adjusted', response.data.recipe)
      prompt.value = ''
    } else {
      error.value = t('recipe.adjust.error')
    }
  } catch (err: unknown) {
    const errorMessage = err instanceof Error ? err.message : 'Unknown error occurred'
    error.value = t('recipe.adjust.errorWithMessage', { message: errorMessage })
  } finally {
    loading.value = false
  }
}

function handleCancel() {
  if (loading.value) return
  prompt.value = ''
  error.value = ''
  emit('close')
}

function handleBackdropClick() {
  if (!loading.value) {
    handleCancel()
  }
}

function handleEscape(event: KeyboardEvent) {
  if (event.key === 'Escape' && props.show && !loading.value) {
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
.adjust-recipe-modal {
  max-width: 550px;
}

.adjust-recipe-modal__description {
  font-size: var(--font-size-base);
  color: var(--color-text);
  line-height: var(--line-height-relaxed);
  margin: 0 0 var(--spacing-md) 0;
}

.adjust-recipe-modal__textarea {
  width: 100%;
  padding: var(--spacing-md);
  font-family: var(--font-family-base);
  font-size: var(--font-size-base);
  line-height: var(--line-height-relaxed);
  border: var(--border-width-thin) solid var(--color-border);
  border-radius: var(--border-radius-md);
  background-color: var(--color-background);
  color: var(--color-text);
  resize: vertical;
  min-height: 120px;
}

.adjust-recipe-modal__textarea:focus {
  outline: none;
  border-color: var(--color-border-focus);
  box-shadow: var(--shadow-focus);
}

.adjust-recipe-modal__textarea::placeholder {
  color: var(--color-text-tertiary);
  white-space: pre-line;
}

.adjust-recipe-modal__textarea:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.adjust-recipe-modal__error {
  padding: var(--spacing-sm) var(--spacing-md);
  margin-bottom: var(--spacing-md);
  background-color: var(--color-error-light);
  color: var(--color-error-dark);
  border-radius: var(--border-radius-md);
  font-size: var(--font-size-sm);
}

.adjust-recipe-modal__submit-btn {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  background: #c25450;
  color: white;
  border: none;
  padding: 10px 20px;
  border-radius: 4px;
  font-weight: 500;
  cursor: pointer;
}

.adjust-recipe-modal__submit-btn:hover:not(:disabled) {
  background: #a8443f;
}

.adjust-recipe-modal__submit-btn:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.sparkle-icon {
  width: 20px;
  height: 20px;
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
