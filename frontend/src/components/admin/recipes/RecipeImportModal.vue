<script setup lang="ts">
import { ref, computed, watch } from 'vue'
import { useI18n } from 'vue-i18n'
import { useAdminStore } from '@/stores/adminStore'
import { useToast } from '@/composables/useToast'
import LoadingSpinner from '@/components/shared/LoadingSpinner.vue'
import ErrorMessage from '@/components/shared/ErrorMessage.vue'
import type { RecipeDetail } from '@/services/types'

const props = defineProps<{
  isOpen: boolean
}>()

const emit = defineEmits<{
  (e: 'close'): void
  (e: 'import', recipe: Partial<RecipeDetail>): void
}>()

const { t } = useI18n()
const adminStore = useAdminStore()
const { showSuccess, showError } = useToast()

const activeTab = ref(0)

const textInput = ref('')
const urlInput = ref('')
const selectedImage = ref<File | null>(null)
const imagePreviewUrl = ref<string | null>(null)

const textLoading = ref(false)
const urlLoading = ref(false)
const imageLoading = ref(false)

const textError = ref<string | null>(null)
const urlError = ref<string | null>(null)
const imageError = ref<string | null>(null)

const MIN_TEXT_LENGTH = 50
const MAX_IMAGE_SIZE = 10 * 1024 * 1024

const tabs = computed(() => [
  { label: t('admin.recipes.import.tabs.text'), id: 0 },
  { label: t('admin.recipes.import.tabs.url'), id: 1 },
  { label: t('admin.recipes.import.tabs.image'), id: 2 }
])

const isLoading = computed(() => textLoading.value || urlLoading.value || imageLoading.value)

const textValid = computed(() => textInput.value.length >= MIN_TEXT_LENGTH)
const urlValid = computed(() => {
  if (!urlInput.value) return false
  try {
    const url = new URL(urlInput.value)
    return url.protocol === 'http:' || url.protocol === 'https:'
  } catch {
    return false
  }
})
const imageValid = computed(() => selectedImage.value !== null)

const textCharCount = computed(() => textInput.value.length)

watch(() => props.isOpen, (newValue) => {
  if (!newValue) {
    resetAll()
  }
})

watch(textInput, () => {
  if (textError.value) textError.value = null
})

watch(urlInput, () => {
  if (urlError.value) urlError.value = null
})

watch(selectedImage, () => {
  if (imageError.value) imageError.value = null
})

function resetAll() {
  textInput.value = ''
  urlInput.value = ''
  selectedImage.value = null
  imagePreviewUrl.value = null
  textError.value = null
  urlError.value = null
  imageError.value = null
  activeTab.value = 0
}

function handleClose() {
  if (isLoading.value) return
  emit('close')
}

async function handleParseText() {
  if (!textValid.value) {
    textError.value = t('admin.recipes.import.errors.textTooShort', { min: MIN_TEXT_LENGTH })
    return
  }

  textLoading.value = true
  textError.value = null

  try {
    const result = await adminStore.parseText({ text: textInput.value })

    if (!result || !validateRecipeData(result)) {
      textError.value = t('admin.recipes.import.errors.incompleteData')
      return
    }

    showSuccess(t('admin.recipes.import.success.text'))
    emit('import', result)
    emit('close')
  } catch (error: any) {
    console.error('Text parsing error:', error)
    textError.value = error.message || t('admin.recipes.import.errors.parseFailed')
  } finally {
    textLoading.value = false
  }
}

async function handleParseUrl() {
  if (!urlValid.value) {
    urlError.value = t('admin.recipes.import.errors.invalidUrl')
    return
  }

  urlLoading.value = true
  urlError.value = null

  try {
    const result = await adminStore.parseUrl({ url: urlInput.value })

    if (!result || !validateRecipeData(result)) {
      urlError.value = t('admin.recipes.import.errors.incompleteData')
      return
    }

    showSuccess(t('admin.recipes.import.success.url'))
    emit('import', result)
    emit('close')
  } catch (error: any) {
    console.error('URL parsing error:', error)
    const message = error.message || t('admin.recipes.import.errors.urlFetchFailed')
    urlError.value = message.includes('404')
      ? t('admin.recipes.import.errors.urlNotFound')
      : message.includes('timeout')
        ? t('admin.recipes.import.errors.urlTimeout')
        : t('admin.recipes.import.errors.urlFetchFailed')
  } finally {
    urlLoading.value = false
  }
}

function handleImageSelect(event: Event) {
  const target = event.target as HTMLInputElement
  const file = target.files?.[0]

  if (!file) return

  if (file.size > MAX_IMAGE_SIZE) {
    imageError.value = t('admin.recipes.import.errors.imageTooLarge', { max: '10MB' })
    return
  }

  const validTypes = ['image/jpeg', 'image/png', 'image/webp', 'image/gif']
  if (!validTypes.includes(file.type)) {
    imageError.value = t('admin.recipes.import.errors.invalidImageType')
    return
  }

  selectedImage.value = file
  imageError.value = null

  const reader = new FileReader()
  reader.onload = (e) => {
    imagePreviewUrl.value = e.target?.result as string
  }
  reader.readAsDataURL(file)
}

function removeImage() {
  selectedImage.value = null
  imagePreviewUrl.value = null
  imageError.value = null
}

async function handleParseImage() {
  if (!imageValid.value || !selectedImage.value) {
    imageError.value = t('admin.recipes.import.errors.noImage')
    return
  }

  imageLoading.value = true
  imageError.value = null

  try {
    const formData = new FormData()
    formData.append('image_file', selectedImage.value)

    const result = await adminStore.parseImage(formData)

    if (!result || !validateRecipeData(result)) {
      imageError.value = t('admin.recipes.import.errors.incompleteData')
      return
    }

    showSuccess(t('admin.recipes.import.success.image'))
    emit('import', result)
    emit('close')
  } catch (error: any) {
    console.error('Image parsing error:', error)
    imageError.value = error.message || t('admin.recipes.import.errors.imageNoRecipe')
  } finally {
    imageLoading.value = false
  }
}

function validateRecipeData(data: any): boolean {
  return !!(
    data.name &&
    data.ingredient_groups &&
    Array.isArray(data.ingredient_groups) &&
    data.ingredient_groups.length > 0 &&
    data.steps &&
    Array.isArray(data.steps) &&
    data.steps.length > 0
  )
}

function handleKeydown(event: KeyboardEvent) {
  if (event.key === 'Escape' && !isLoading.value) {
    handleClose()
  }

  if (event.ctrlKey && event.key === 'Enter' && activeTab.value === 0 && textValid.value) {
    handleParseText()
  }
}
</script>

<template>
  <div
    v-if="isOpen"
    class="recipe-import-modal-overlay"
    @click.self="handleClose"
    @keydown="handleKeydown"
    tabindex="-1"
  >
    <div class="recipe-import-modal" role="dialog" aria-modal="true">
      <div class="recipe-import-modal__header">
        <h2>{{ t('admin.recipes.import.title') }}</h2>
        <button
          class="recipe-import-modal__close"
          @click="handleClose"
          :disabled="isLoading"
          :aria-label="t('common.actions.close')"
        >
          <i class="pi pi-times"></i>
        </button>
      </div>

      <div class="recipe-import-modal__tabs">
        <button
          v-for="tab in tabs"
          :key="tab.id"
          class="tab"
          :class="{ 'tab--active': activeTab === tab.id }"
          @click="activeTab = tab.id"
          :disabled="isLoading"
        >
          {{ tab.label }}
        </button>
      </div>

      <div class="recipe-import-modal__content">
        <div v-if="activeTab === 0" class="tab-content">
          <label class="form-label">
            {{ t('admin.recipes.import.textLabel') }}
          </label>
          <textarea
            v-model="textInput"
            class="form-textarea"
            rows="12"
            :placeholder="t('admin.recipes.import.textPlaceholder')"
            :disabled="textLoading"
          ></textarea>
          <div class="char-counter">
            {{ t('admin.recipes.import.charCount', { count: textCharCount, min: MIN_TEXT_LENGTH }) }}
          </div>

          <ErrorMessage v-if="textError" :message="textError" />

          <LoadingSpinner
            v-if="textLoading"
            :text="t('admin.recipes.import.loading.analyzingText')"
            :center="true"
          />

          <button
            v-if="!textLoading"
            class="btn btn-primary"
            @click="handleParseText"
            :disabled="!textValid"
          >
            <i class="pi pi-sparkles"></i>
            {{ t('admin.recipes.import.parseButton') }}
          </button>
        </div>

        <div v-else-if="activeTab === 1" class="tab-content">
          <label class="form-label">
            {{ t('admin.recipes.import.urlLabel') }}
          </label>
          <input
            type="url"
            v-model="urlInput"
            class="form-input"
            :placeholder="t('admin.recipes.import.urlPlaceholder')"
            :disabled="urlLoading"
          />

          <p class="hint-text">
            {{ t('admin.recipes.import.urlHint') }}
          </p>

          <ErrorMessage v-if="urlError" :message="urlError" />

          <LoadingSpinner
            v-if="urlLoading"
            :text="t('admin.recipes.import.loading.fetchingUrl')"
            :center="true"
          />

          <button
            v-if="!urlLoading"
            class="btn btn-primary"
            @click="handleParseUrl"
            :disabled="!urlValid"
          >
            <i class="pi pi-sparkles"></i>
            {{ t('admin.recipes.import.parseButton') }}
          </button>
        </div>

        <div v-else-if="activeTab === 2" class="tab-content">
          <label class="form-label">
            {{ t('admin.recipes.import.imageLabel') }}
          </label>

          <div v-if="!selectedImage" class="image-upload-zone">
            <input
              type="file"
              id="image-upload"
              accept="image/jpeg,image/png,image/webp,image/gif"
              @change="handleImageSelect"
              :disabled="imageLoading"
              class="image-upload-input"
            />
            <label for="image-upload" class="image-upload-label">
              <i class="pi pi-cloud-upload"></i>
              <p>{{ t('admin.recipes.import.imageDragText') }}</p>
              <p class="hint-text">{{ t('admin.recipes.import.imageHint') }}</p>
            </label>
          </div>

          <div v-else class="image-preview">
            <img :src="imagePreviewUrl" alt="Recipe preview" />
            <p class="image-filename">{{ selectedImage.name }}</p>
            <button v-if="!imageLoading" class="btn btn-outline" @click="removeImage">
              <i class="pi pi-trash"></i>
              {{ t('common.actions.remove') }}
            </button>
          </div>

          <ErrorMessage v-if="imageError" :message="imageError" />

          <LoadingSpinner
            v-if="imageLoading"
            :text="t('admin.recipes.import.loading.analyzingImage')"
            :center="true"
          />

          <button
            v-if="!imageLoading && selectedImage"
            class="btn btn-primary"
            @click="handleParseImage"
            :disabled="!imageValid"
          >
            <i class="pi pi-sparkles"></i>
            {{ t('admin.recipes.import.parseButton') }}
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.recipe-import-modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background-color: rgba(0, 0, 0, 0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: var(--z-index-modal, 1000);
  padding: var(--spacing-md);
}

.recipe-import-modal {
  background: var(--color-background);
  border-radius: var(--border-radius-lg);
  box-shadow: var(--shadow-xl);
  max-width: 700px;
  width: 100%;
  max-height: 90vh;
  display: flex;
  flex-direction: column;
}

.recipe-import-modal__header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: var(--spacing-lg);
  border-bottom: 1px solid var(--color-border);
}

.recipe-import-modal__header h2 {
  margin: 0;
  font-size: var(--font-size-xl);
  font-weight: var(--font-weight-semibold);
}

.recipe-import-modal__close {
  background: none;
  border: none;
  cursor: pointer;
  padding: var(--spacing-sm);
  color: var(--color-text-secondary);
  font-size: var(--font-size-xl);
  line-height: 1;
}

.recipe-import-modal__close:hover:not(:disabled) {
  color: var(--color-text);
}

.recipe-import-modal__close:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.recipe-import-modal__tabs {
  display: flex;
  border-bottom: 1px solid var(--color-border);
  padding: 0 var(--spacing-lg);
}

.tab {
  background: none;
  border: none;
  padding: var(--spacing-md) var(--spacing-lg);
  cursor: pointer;
  color: var(--color-text-secondary);
  font-weight: var(--font-weight-medium);
  border-bottom: 2px solid transparent;
  transition: all var(--transition-fast);
}

.tab:hover:not(:disabled) {
  color: var(--color-text);
}

.tab--active {
  color: var(--color-primary);
  border-bottom-color: var(--color-primary);
}

.tab:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.recipe-import-modal__content {
  padding: var(--spacing-lg);
  overflow-y: auto;
  flex: 1;
}

.tab-content {
  display: flex;
  flex-direction: column;
  gap: var(--spacing-md);
}

.form-label {
  font-weight: var(--font-weight-medium);
  margin-bottom: var(--spacing-xs);
}

.form-textarea {
  width: 100%;
  padding: var(--spacing-md);
  border: 1px solid var(--color-border);
  border-radius: var(--border-radius-md);
  font-family: inherit;
  font-size: var(--font-size-base);
  resize: vertical;
}

.form-input {
  width: 100%;
  padding: var(--spacing-md);
  border: 1px solid var(--color-border);
  border-radius: var(--border-radius-md);
  font-size: var(--font-size-base);
}

.char-counter {
  font-size: var(--font-size-sm);
  color: var(--color-text-secondary);
  text-align: right;
}

.hint-text {
  font-size: var(--font-size-sm);
  color: var(--color-text-secondary);
  margin: 0;
}

.image-upload-zone {
  border: 2px dashed var(--color-border);
  border-radius: var(--border-radius-md);
  padding: var(--spacing-2xl);
  text-align: center;
  transition: border-color var(--transition-fast);
}

.image-upload-zone:hover {
  border-color: var(--color-primary);
}

.image-upload-input {
  display: none;
}

.image-upload-label {
  cursor: pointer;
  display: block;
}

.image-upload-label i {
  font-size: 3rem;
  color: var(--color-text-secondary);
  margin-bottom: var(--spacing-md);
}

.image-upload-label p {
  margin: var(--spacing-sm) 0;
}

.image-preview {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: var(--spacing-md);
}

.image-preview img {
  max-width: 100%;
  max-height: 300px;
  border-radius: var(--border-radius-md);
  box-shadow: var(--shadow-md);
}

.image-filename {
  font-size: var(--font-size-sm);
  color: var(--color-text-secondary);
  margin: 0;
}

.btn {
  padding: var(--spacing-md) var(--spacing-lg);
  border-radius: var(--border-radius-md);
  font-weight: var(--font-weight-medium);
  cursor: pointer;
  transition: all var(--transition-fast);
  display: inline-flex;
  align-items: center;
  gap: var(--spacing-sm);
  border: none;
  font-size: var(--font-size-base);
}

.btn-primary {
  background: var(--color-primary);
  color: white;
}

.btn-primary:hover:not(:disabled) {
  background: var(--color-primary-dark);
}

.btn-primary:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.btn-outline {
  background: transparent;
  border: 1px solid var(--color-border);
  color: var(--color-text);
}

.btn-outline:hover {
  background: var(--color-background-secondary);
}

@media (max-width: 768px) {
  .recipe-import-modal {
    max-width: 100%;
    max-height: 100vh;
    border-radius: 0;
  }

  .recipe-import-modal__tabs {
    overflow-x: auto;
  }

  .tab {
    white-space: nowrap;
  }
}
</style>
