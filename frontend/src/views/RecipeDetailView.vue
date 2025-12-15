<template>
  <!-- Edit Mode: Two panels centered -->
  <div v-if="isEditMode" class="edit-mode">
    <MainNavBar :show-search="true" @search="handleSearch" />

    <div class="edit-mode__container">
      <!-- Edit Form Panel -->
      <div class="edit-mode__form-panel">
        <div class="edit-mode__form-header">
          <h2 class="edit-mode__form-title">{{ $t('common.buttons.edit') }}</h2>
          <div class="edit-mode__form-actions">
            <button
              class="edit-mode__btn edit-mode__btn--save"
              :disabled="saving || !hasUnsavedChanges || !(recipeFormRef?.isValid)"
              @click="handleSaveRecipe"
            >
              <i v-if="saving" class="pi pi-spinner pi-spin"></i>
              <i v-else-if="saveSuccess" class="pi pi-check"></i>
              <span v-if="saveSuccess">{{ $t('common.messages.saved') }}</span>
              <span v-else>{{ $t('common.buttons.save') }}</span>
            </button>
            <button class="edit-mode__btn edit-mode__btn--close" @click="exitEditMode">
              {{ $t('common.buttons.close') }}
            </button>
          </div>
        </div>
        <div class="edit-mode__form-content">
          <div v-if="editLoading" class="edit-mode__loading">
            <i class="pi pi-spinner pi-spin"></i>
            <p>{{ $t('common.messages.loading') }}</p>
          </div>
          <div v-else-if="editError" class="edit-mode__error">
            <i class="pi pi-exclamation-triangle"></i>
            <p>{{ editError.message }}</p>
            <button class="edit-mode__btn" @click="fetchRecipeForEdit">
              {{ $t('common.buttons.retry') }}
            </button>
          </div>
          <RecipeForm
            v-else
            ref="recipeFormRef"
            :model-value="formData"
            hide-import
            @update:model-value="handleFormUpdate"
          />
        </div>
      </div>

      <!-- Recipe Preview Panel -->
      <div class="edit-mode__preview-panel recipe-display">
        <template v-if="recipe">
          <div class="recipe-image">
            <img
              v-if="recipe.detail_image_url || recipe.image_url"
              :src="recipe.detail_image_url || recipe.image_url"
              :alt="recipe.name"
              class="recipe-image__img"
            />
            <p v-if="recipe.image_ai_generated" class="recipe-image__caption">
              {{ $t('recipe.view.aiImageCaption') }}
            </p>
          </div>

          <div class="recipe-info">
            <div class="recipe-info__title-row">
              <h1 class="recipe-info__title">{{ recipe.name }}</h1>
              <FavoriteButton
                :recipe-id="recipe.id"
                :is-favorite="recipe.favorite || false"
                size="medium"
                @update:is-favorite="recipe.favorite = $event"
                @require-login="showLoginModal = true"
              />
            </div>

            <p class="recipe-info__meta">
              <span v-if="recipe.timing?.total_minutes">{{ recipe.timing.total_minutes }}{{ $t('admin.recipes.table.minutes') }}</span>
              <span v-if="recipe.servings?.original">{{ recipe.servings.original }} {{ $t('common.labels.servings') }}</span>
              <span v-if="recipe.difficulty_level">{{ $t(`forms.recipe.difficultyLevels.${recipe.difficulty_level}`) }}</span>
              <span v-if="recipe.cuisines?.length">{{ recipe.cuisines.join(', ') }}</span>
              <span v-if="recipe.dietary_tags?.length">{{ recipe.dietary_tags.join(', ') }}</span>
            </p>

            <div v-if="recipe.tags?.length" class="recipe-info__tags">
              <span v-for="tag in recipe.tags" :key="tag" class="recipe-tag">{{ tag }}</span>
            </div>

            <p v-if="recipe.description" class="recipe-info__description">{{ recipe.description }}</p>

            <div class="recipe-ingredients">
              <h2 class="recipe-section__title">{{ $t('recipe.view.ingredients') }}</h2>
              <div v-for="(group, groupIndex) in recipe.ingredient_groups" :key="groupIndex" class="ingredient-group">
                <h3 v-if="group.name" class="ingredient-group__name">{{ group.name }}</h3>
                <ul class="ingredient-list">
                  <li v-for="(item, itemIndex) in group.items" :key="itemIndex" class="ingredient-item">
                    <span v-if="item.amount" class="ingredient-item__amount">{{ item.amount }} {{ item.unit }} </span>
                    <span class="ingredient-item__name">{{ item.name }}</span>
                    <span v-if="item.preparation" class="ingredient-item__prep"> ({{ item.preparation }})</span>
                    <span v-if="item.optional" class="ingredient-item__optional"> ({{ $t('recipe.view.optional') }})</span>
                  </li>
                </ul>
              </div>
            </div>
          </div>

          <div class="recipe-steps">
            <h2 class="recipe-section__title">{{ $t('recipe.view.steps') }}</h2>
            <div class="steps-list">
              <div v-for="(step, index) in recipe.steps" :key="index" class="step-item">
                <h3 v-if="step.section_heading" class="step-section-heading">{{ step.section_heading }}</h3>
                <p class="step-item__text">{{ step.instruction }}</p>
              </div>
            </div>
          </div>
        </template>
      </div>
    </div>

    <LoginModal :show="showLoginModal" @close="showLoginModal = false" />
  </div>

  <!-- View Mode: Standard layout -->
  <PageLayout v-else class="recipe-detail-page">
    <template #navbar>
      <MainNavBar :show-search="true" @search="handleSearch" />
    </template>

    <template #left-sidebar>
      <button class="back-button" @click="goBack">
        <span class="back-button__arrow">←</span>
        <span class="back-button__text">{{ $t('common.buttons.back') }}</span>
      </button>
      <button
        v-if="isAdmin && recipe"
        class="edit-button"
        @click="enterEditMode"
      >
        {{ $t('common.buttons.edit') }}
      </button>
    </template>

    <LoadingSpinner v-if="loading" :center="true" />
    <ErrorMessage v-else-if="error" :message="error" severity="error" />
    <div v-else-if="recipe" class="recipe-display">
      <div class="recipe-image">
        <img
          v-if="recipe.detail_image_url || recipe.image_url"
          :src="recipe.detail_image_url || recipe.image_url"
          :alt="recipe.name"
          class="recipe-image__img"
        />
        <p v-if="recipe.image_ai_generated" class="recipe-image__caption">
          {{ $t('recipe.view.aiImageCaption') }}
        </p>
      </div>

      <div class="recipe-info">
        <div class="recipe-info__title-row">
          <h1 class="recipe-info__title">{{ recipe.name }}</h1>
          <FavoriteButton
            :recipe-id="recipe.id"
            :is-favorite="recipe.favorite || false"
            size="medium"
            @update:is-favorite="recipe.favorite = $event"
            @require-login="showLoginModal = true"
          />
          <span v-if="isAiAdjusted" class="adjusted-tag">{{ $t('recipe.view.adjusted') }}</span>
        </div>

        <p class="recipe-info__meta">
          <span v-if="recipe.timing?.total_minutes">{{ recipe.timing.total_minutes }}{{ $t('admin.recipes.table.minutes') }}</span>
          <span v-if="recipe.servings?.original">{{ recipe.servings.original }} {{ $t('common.labels.servings') }}</span>
          <span v-if="recipe.difficulty_level">{{ $t(`forms.recipe.difficultyLevels.${recipe.difficulty_level}`) }}</span>
          <span v-if="recipe.cuisines?.length">{{ recipe.cuisines.join(', ') }}</span>
          <span v-if="recipe.dietary_tags?.length">{{ recipe.dietary_tags.join(', ') }}</span>
        </p>

        <div v-if="recipe.tags?.length" class="recipe-info__tags">
          <span v-for="tag in recipe.tags" :key="tag" class="recipe-tag">{{ tag }}</span>
        </div>

        <p v-if="recipe.description" class="recipe-info__description">{{ recipe.description }}</p>

        <div v-if="displayedNutrition" class="nutrition-wrapper">
          <div class="nutrition-toggle">
            <button
              class="nutrition-toggle__btn"
              :class="{ 'nutrition-toggle__btn--active': !showTotalNutrition }"
              @click="showTotalNutrition = false"
            >
              {{ $t('recipe.view.perServing') }}
            </button>
            <button
              class="nutrition-toggle__btn"
              :class="{ 'nutrition-toggle__btn--active': showTotalNutrition }"
              @click="showTotalNutrition = true"
            >
              {{ currentServings }} {{ currentServings === 1 ? $t('common.labels.Serving') : $t('common.labels.Servings') }}
            </button>
          </div>
          <div class="nutrition-info">
            <div class="nutrition-info__item">
              <span class="nutrition-info__label">{{ $t('recipe.view.cals') }}</span>
              <span class="nutrition-info__value">{{ displayedNutrition.calories }}</span>
              <NutritionSparkle
                :current-value="perServingNutrition?.calories"
                :original-value="getOriginalNutrition('calories')"
              />
            </div>
            <div class="nutrition-info__item">
              <span class="nutrition-info__label">{{ $t('recipe.view.carbs') }}</span>
              <span class="nutrition-info__value">{{ displayedNutrition.carbs_g }}g</span>
              <NutritionSparkle
                :current-value="perServingNutrition?.carbs_g"
                :original-value="getOriginalNutrition('carbs_g')"
                suffix="g"
              />
            </div>
            <div class="nutrition-info__item">
              <span class="nutrition-info__label">{{ $t('recipe.view.protein') }}</span>
              <span class="nutrition-info__value">{{ displayedNutrition.protein_g }}g</span>
              <NutritionSparkle
                :current-value="perServingNutrition?.protein_g"
                :original-value="getOriginalNutrition('protein_g')"
                suffix="g"
              />
            </div>
            <div class="nutrition-info__item">
              <span class="nutrition-info__label">{{ $t('recipe.view.fat') }}</span>
              <span class="nutrition-info__value">{{ displayedNutrition.fat_g }}g</span>
              <NutritionSparkle
                :current-value="perServingNutrition?.fat_g"
                :original-value="getOriginalNutrition('fat_g')"
                suffix="g"
              />
            </div>
          </div>
        </div>

        <div class="servings-adjuster">
          <div class="servings-adjuster__controls">
            <button class="servings-adjuster__btn servings-adjuster__btn--minus" @click="decrementServings">
              <span>-</span>
            </button>
            <span class="servings-adjuster__value">{{ currentServings }} {{ currentServings === 1 ? $t('common.labels.Serving') : $t('common.labels.Servings') }}</span>
            <button class="servings-adjuster__btn" @click="incrementServings">
              <span>+</span>
            </button>
          </div>
          <button class="servings-adjuster__adjust-btn" @click="showAdjustModal = true">
            {{ $t('recipe.view.adjustRecipe') }} <img src="@/assets/images/sparkles.svg" alt="" class="sparkle-icon" />
          </button>
        </div>

        <div v-if="isAiAdjusted" class="ai-disclaimer">
          <p class="ai-disclaimer__text">{{ $t('recipe.view.aiAdjustmentDisclaimer') }}</p>
          <a href="#" class="ai-disclaimer__restore" @click.prevent="restoreToOriginal">{{ $t('recipe.view.restoreToOriginal') }}</a>
        </div>

        <div class="recipe-ingredients">
          <h2 class="recipe-section__title">{{ $t('recipe.view.ingredients') }}</h2>
          <div v-for="(group, groupIndex) in scaledIngredientGroups" :key="groupIndex" class="ingredient-group">
            <h3 v-if="group.name" class="ingredient-group__name">{{ group.name }}</h3>
            <ul class="ingredient-list">
              <li v-for="(item, itemIndex) in group.items" :key="itemIndex" class="ingredient-item">
                <AdjustedIngredientLine
                  :current="getCurrentRawIngredient(groupIndex, itemIndex)"
                  :original="getOriginalIngredient(groupIndex, itemIndex)"
                  :is-ai-adjusted="isAiAdjusted"
                >
                  <span v-if="item.displayAmount" :key="amountFlashKey" class="ingredient-item__amount" :class="{ 'ingredient-item__amount--flash': amountFlashKey > 0 }">{{ item.displayAmount }} </span>
                  <span class="ingredient-item__name">{{ item.name }}</span>
                  <span v-if="item.equivalentNote" class="ingredient-item__equivalent"> {{ item.equivalentNote }}</span>
                  <span v-if="item.preparation" class="ingredient-item__prep"> ({{ item.preparation }})</span>
                  <span v-if="item.optional" class="ingredient-item__optional"> ({{ $t('recipe.view.optional') }})</span>
                </AdjustedIngredientLine>
              </li>
            </ul>
          </div>
        </div>
      </div>

      <div class="recipe-steps">
        <div class="recipe-steps__header">
          <h2 class="recipe-section__title">{{ $t('recipe.view.steps') }}</h2>
          <button
            v-if="hasStepImages"
            class="step-images-toggle"
            @click="showStepImages = !showStepImages"
          >
            <i :class="showStepImages ? 'pi pi-eye' : 'pi pi-eye-slash'"></i>
            <span>{{ $t('recipe.view.images') }}</span>
          </button>
        </div>
        <div class="steps-list">
          <template v-for="item in stepsWithImages" :key="item.type === 'step' ? `step-${item.data.id}` : `img-${item.data.id}`">
            <div v-if="item.type === 'step'" class="step-item">
              <h3 v-if="item.data.section_heading" class="step-section-heading">{{ item.data.section_heading }}</h3>
              <p class="step-item__text">
                <AdjustedText
                  :current-value="item.data.instruction"
                  :original-value="getOriginalStep(item.stepIndex)?.instruction"
                  :is-ai-adjusted="isAiAdjusted"
                >{{ item.data.instruction }}</AdjustedText>
              </p>
            </div>
            <div v-else-if="showStepImages" class="step-image">
              <div class="step-image__wrapper">
                <img
                  v-if="item.data.url"
                  :src="item.data.url"
                  :alt="item.data.caption || ''"
                  class="step-image__img"
                />
                <img
                  v-if="item.data.ai_generated"
                  src="@/assets/images/sparkles.svg"
                  alt=""
                  class="step-image__ai-badge"
                />
              </div>
              <p v-if="item.data.caption" class="step-image__caption">{{ item.data.caption }}</p>
            </div>
          </template>
        </div>
      </div>
    </div>

    <AdjustRecipeModal
      :show="showAdjustModal"
      :recipe="displayRecipe"
      @close="showAdjustModal = false"
      @adjusted="handleRecipeAdjusted"
    />

    <LoginModal :show="showLoginModal" @close="showLoginModal = false" />
  </PageLayout>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useI18n } from 'vue-i18n'
import { recipeApi } from '@/services/recipeApi'
import { adminApi } from '@/services/adminApi'
import type { RecipeDetail, RecipeStep, RecipeStepImage } from '@/services/types'
import { useAuth } from '@/composables/useAuth'
import { useRecipeSave } from '@/composables/useRecipeSave'
import { useDataReferenceStore, useUiStore } from '@/stores'
import PageLayout from '@/components/layout/PageLayout.vue'
import MainNavBar from '@/components/shared/MainNavBar.vue'
import LoadingSpinner from '@/components/shared/LoadingSpinner.vue'
import ErrorMessage from '@/components/shared/ErrorMessage.vue'
import AdjustRecipeModal from '@/components/recipe/AdjustRecipeModal.vue'
import AdjustedText from '@/components/recipe/AdjustedText.vue'
import AdjustedIngredientLine from '@/components/recipe/AdjustedIngredientLine.vue'
import NutritionSparkle from '@/components/recipe/NutritionSparkle.vue'
import LoginModal from '@/components/shared/LoginModal.vue'
import FavoriteButton from '@/components/shared/FavoriteButton.vue'
import RecipeForm from '@/components/admin/recipes/RecipeForm.vue'
import { useRecipeScaling } from '@/composables/useRecipeScaling'
import { findMatchingIngredient, findMatchingStep } from '@/composables/useRecipeDiff'

const route = useRoute()
const router = useRouter()
const { t, locale } = useI18n()
const { isAdmin } = useAuth()
const dataStore = useDataReferenceStore()
const uiStore = useUiStore()
const { saving, saveRecipe } = useRecipeSave()

const recipe = ref<RecipeDetail | null>(null)
const loading = ref(true)
const error = ref<string | null>(null)

const showAdjustModal = ref(false)
const showLoginModal = ref(false)
const isEditMode = ref(false)
const adjustedRecipe = ref<RecipeDetail | null>(null)
const previousRecipe = ref<RecipeDetail | null>(null)
const isAiAdjusted = ref(false)
const showTotalNutrition = ref(false)
const showStepImages = ref(true)
const amountFlashKey = ref(0)
const isInitialLoad = ref(true)

// Edit mode state
const formData = ref<Partial<RecipeDetail>>({})
const editLoading = ref(false)
const editError = ref<Error | null>(null)
const recipeFormRef = ref<InstanceType<typeof RecipeForm> | null>(null)
const hasUnsavedChanges = ref(false)
const saveSuccess = ref(false)

const displayRecipe = computed(() => adjustedRecipe.value || recipe.value)

const hasStepImages = computed(() => {
  return (displayRecipe.value?.step_images?.length ?? 0) > 0
})

type StepItem = { type: 'step'; data: RecipeStep; stepIndex: number }
type ImageItem = { type: 'image'; data: RecipeStepImage }
type StepsAndImages = (StepItem | ImageItem)[]

const stepsWithImages = computed<StepsAndImages>(() => {
  if (!displayRecipe.value) return []

  const steps = displayRecipe.value.steps || []
  const images = displayRecipe.value.step_images || []

  const items: StepsAndImages = [
    ...steps.map((step, idx) => ({ type: 'step' as const, data: step, stepIndex: idx })),
    ...images.map(img => ({ type: 'image' as const, data: img }))
  ]

  items.sort((a, b) => {
    const posA = a.type === 'step' ? a.data.order : a.data.position
    const posB = b.type === 'step' ? b.data.order : b.data.position
    return posA - posB
  })

  return items
})

const {
  currentServings,
  originalServings,
  scaledIngredientGroups,
  increment: incrementServings,
  decrement: decrementServings,
} = useRecipeScaling(displayRecipe)

watch(currentServings, () => {
  if (isInitialLoad.value) {
    isInitialLoad.value = false
    return
  }
  amountFlashKey.value++
})

const perServingNutrition = computed(() => {
  const nutrition = displayRecipe.value?.nutrition?.per_serving
  if (!nutrition) return null

  return {
    calories: Math.round(nutrition.calories),
    carbs_g: Math.round(nutrition.carbs_g * 10) / 10,
    protein_g: Math.round(nutrition.protein_g * 10) / 10,
    fat_g: Math.round(nutrition.fat_g * 10) / 10,
  }
})

const totalNutrition = computed(() => {
  const nutrition = displayRecipe.value?.nutrition?.per_serving
  if (!nutrition) return null

  const scale = currentServings.value
  return {
    calories: Math.round(nutrition.calories * scale),
    carbs_g: Math.round(nutrition.carbs_g * scale * 10) / 10,
    protein_g: Math.round(nutrition.protein_g * scale * 10) / 10,
    fat_g: Math.round(nutrition.fat_g * scale * 10) / 10,
  }
})

const displayedNutrition = computed(() => {
  return showTotalNutrition.value ? totalNutrition.value : perServingNutrition.value
})

function handleRecipeAdjusted(newRecipe: RecipeDetail) {
  previousRecipe.value = displayRecipe.value ? JSON.parse(JSON.stringify(displayRecipe.value)) : null
  adjustedRecipe.value = newRecipe
  isAiAdjusted.value = true
  showAdjustModal.value = false
  currentServings.value = newRecipe.servings?.original || currentServings.value
}

function restoreToOriginal() {
  adjustedRecipe.value = null
  previousRecipe.value = null
  isAiAdjusted.value = false
  currentServings.value = recipe.value?.servings?.original || currentServings.value
}

function formatIngredientAmount(amount?: string, unit?: string): string {
  if (!amount) return ''
  return unit ? `${amount} ${unit}` : amount
}

function getOriginalIngredient(groupIndex: number, itemIndex: number) {
  if (!previousRecipe.value?.ingredient_groups) return null
  if (!displayRecipe.value?.ingredient_groups) return null

  const currentGroup = displayRecipe.value.ingredient_groups[groupIndex]
  if (!currentGroup?.items) return null

  const currentItem = currentGroup.items[itemIndex]
  if (!currentItem) return null

  return findMatchingIngredient(currentItem, previousRecipe.value.ingredient_groups)
}

function getCurrentRawIngredient(groupIndex: number, itemIndex: number) {
  if (!displayRecipe.value?.ingredient_groups) return null
  const group = displayRecipe.value.ingredient_groups[groupIndex]
  if (!group?.items) return null
  const item = group.items[itemIndex]
  if (!item) return null

  return {
    ...item,
    displayAmount: formatIngredientAmount(item.amount, item.unit)
  }
}

function getOriginalStep(stepIndex: number) {
  if (!previousRecipe.value?.steps) return null
  if (!displayRecipe.value?.steps) return null

  const currentStep = displayRecipe.value.steps[stepIndex]
  if (!currentStep) return null

  return findMatchingStep(currentStep, previousRecipe.value.steps)
}

function getOriginalNutrition(key: 'calories' | 'carbs_g' | 'protein_g' | 'fat_g'): number | null {
  if (!previousRecipe.value?.nutrition?.per_serving) return null
  const value = previousRecipe.value.nutrition.per_serving[key]
  if (key === 'calories') return Math.round(value)
  return value
}

async function loadRecipe() {
  try {
    loading.value = true
    error.value = null
    const recipeId = Number(route.params.id)
    const response = await recipeApi.getRecipe(recipeId, locale.value as any)

    if (response.success) {
      recipe.value = response.data.recipe
      currentServings.value = recipe.value.servings?.original || 2
    } else {
      error.value = response.message || t('common.messages.error')
    }
  } catch (err) {
    error.value = err instanceof Error ? err.message : t('common.messages.error')
  } finally {
    loading.value = false
  }
}

function handleSearch(query: string) {
  if (query.trim()) {
    router.push({ name: 'home', query: { q: query } })
  } else {
    router.push({ name: 'home' })
  }
}

function goBack() {
  if (window.history.length > 1) {
    router.back()
  } else {
    router.push({ name: 'home' })
  }
}

// Edit mode functions
async function enterEditMode() {
  isEditMode.value = true
  await fetchRecipeForEdit()
}

function exitEditMode() {
  isEditMode.value = false
  hasUnsavedChanges.value = false
  saveSuccess.value = false
  formData.value = {}
}

async function fetchRecipeForEdit() {
  if (!recipe.value) return

  editLoading.value = true
  editError.value = null
  saveSuccess.value = false

  try {
    const [recipeResponse] = await Promise.all([
      adminApi.getRecipe(String(recipe.value.id), uiStore.language),
      dataStore.fetchAll()
    ])

    if (recipeResponse.success && recipeResponse.data) {
      formData.value = recipeResponse.data.recipe
    }
  } catch (e) {
    editError.value = e instanceof Error ? e : new Error('Failed to fetch recipe')
  } finally {
    editLoading.value = false
  }
}

function handleFormUpdate(newValue: Partial<RecipeDetail>) {
  formData.value = newValue
  hasUnsavedChanges.value = true
  saveSuccess.value = false
}

async function handleSaveRecipe() {
  if (!recipeFormRef.value?.validateForm() || !recipe.value) {
    return
  }

  const imageFile = recipeFormRef.value.selectedImageFile
  const result = await saveRecipe(String(recipe.value.id), formData.value, imageFile)

  if (result.success && result.data) {
    saveSuccess.value = true
    hasUnsavedChanges.value = false
    recipe.value = result.data
    adjustedRecipe.value = null
    previousRecipe.value = null
    isAiAdjusted.value = false
    currentServings.value = result.data.servings?.original || currentServings.value
  }
}

onMounted(() => {
  loadRecipe()
})

watch(locale, () => {
  loadRecipe()
})
</script>

<style>
@import '@/assets/styles/recipe-display.css';
</style>

<style scoped>
/* Edit Mode Layout */
.edit-mode {
  height: 100vh;
  background: var(--color-provisions-bg);
  display: flex;
  flex-direction: column;
  overflow: hidden;
}

.edit-mode__container {
  display: flex;
  justify-content: center;
  flex: 1;
  overflow: hidden;
}

.edit-mode__form-panel {
  width: 600px;
  height: 100%;
  flex-shrink: 0;
  background: var(--color-provisions-bg);
  border-left: 1px solid var(--color-provisions-border);
  border-right: 1px solid var(--color-provisions-border);
  display: flex;
  flex-direction: column;
  overflow: hidden;
}

.edit-mode__form-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 16px 24px;
  border-bottom: 1px solid var(--color-provisions-border);
  flex-shrink: 0;
}

.edit-mode__form-title {
  font-family: var(--font-family-heading);
  font-size: 18px;
  font-weight: 600;
  margin: 0;
  color: var(--color-provisions-text-dark);
}

.edit-mode__form-actions {
  display: flex;
  gap: 8px;
}

.edit-mode__btn {
  padding: 8px 16px;
  border-radius: 4px;
  font-family: var(--font-family-base);
  font-size: 14px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.15s;
  display: flex;
  align-items: center;
  gap: 6px;
}

.edit-mode__btn--save {
  background: var(--color-error);
  color: white;
  border: none;
}

.edit-mode__btn--save:hover:not(:disabled) {
  background: var(--color-error-dark);
}

.edit-mode__btn--save:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.edit-mode__btn--close {
  background: transparent;
  color: var(--color-provisions-text-dark);
  border: 1px solid var(--color-provisions-border);
}

.edit-mode__btn--close:hover {
  background: var(--color-provisions-card-bg);
}

.edit-mode__form-content {
  flex: 1;
  overflow-y: auto;
  padding: 24px;
}

.edit-mode__loading,
.edit-mode__error {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 48px;
  color: var(--color-provisions-text-muted);
  text-align: center;
}

.edit-mode__loading i,
.edit-mode__error i {
  font-size: 32px;
  margin-bottom: 16px;
}

.edit-mode__error {
  color: var(--color-error);
}

.edit-mode__error .edit-mode__btn {
  margin-top: 16px;
  background: var(--color-error);
  color: white;
  border: none;
}

.edit-mode__preview-panel {
  width: 600px;
  height: 100%;
  flex-shrink: 0;
  background: var(--color-provisions-bg);
  border-right: 1px solid var(--color-provisions-border);
  overflow-y: auto;
}

/* View Mode Styles */
.recipe-detail-page {
  font-size: 16px;
}

.back-button {
  position: sticky;
  top: var(--spacing-lg);
  margin-left: auto;
  margin-right: var(--spacing-lg);
  margin-top: var(--spacing-lg);
  display: flex;
  align-items: center;
  gap: 6px;
  padding: 8px 12px;
  background: transparent;
  border: none;
  cursor: pointer;
  font-family: var(--font-family-heading);
  font-size: 16px;
  font-weight: 600;
  color: var(--color-provisions-border);
  transition: color 0.15s;
}

.back-button:hover {
  color: var(--color-provisions-text-dark);
}

.back-button__arrow {
  font-size: 18px;
}

.edit-button {
  margin-left: auto;
  margin-right: var(--spacing-lg);
  margin-top: var(--spacing-sm);
  display: flex;
  align-items: center;
  gap: 6px;
  padding: 8px 12px;
  background: transparent;
  border: none;
  cursor: pointer;
  font-family: var(--font-family-heading);
  font-size: 16px;
  font-weight: 600;
  color: var(--color-provisions-border);
  text-decoration: none;
  transition: color 0.15s;
}

.edit-button:hover {
  color: var(--color-provisions-text-dark);
}

/* Recipe Image (caption is view-specific) */
.recipe-image__caption {
  font-size: 12px;
  color: var(--color-provisions-text-muted);
  opacity: 0.5;
  text-align: center;
  padding: 8px 16px;
  margin: 0;
}

/* Recipe Info (view-specific extensions) */
.recipe-info__title-row {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 8px;
}

.adjusted-tag {
  display: inline-flex;
  align-items: center;
  padding: 4px 10px;
  background: #c25450;
  color: white;
  font-size: 12px;
  font-family: var(--font-family-base);
  font-weight: 500;
  border-radius: 3px;
  white-space: nowrap;
}

.recipe-info__title {
  font-family: var(--font-family-heading);
  font-size: 24px;
  font-weight: 600;
  margin: 0;
  color: var(--color-provisions-text-dark);
  line-height: 1.2;
  flex: 1;
}

.recipe-info__meta {
  font-size: inherit;
  color: var(--color-provisions-border);
  margin: 0 0 10px 0;
  font-family: var(--font-family-base);
  font-weight: 300;
  line-height: 1.8;
}

.recipe-info__meta span {
  display: inline;
}

.recipe-info__meta span:not(:last-child)::after {
  content: " · ";
  margin: 0 0.3em;
}

.recipe-info__tags {
  display: flex;
  gap: 6px;
  margin-bottom: 40px;
  flex-wrap: wrap;
}

.recipe-tag {
  display: inline-block;
  padding: 4px 10px;
  background: #d5d5d5;
  color: var(--color-provisions-text-dark);
  font-size: 12px;
  font-family: var(--font-family-base);
  font-weight: 400;
  border-radius: 3px;
}

.recipe-info__description {
  font-size: inherit;
  color: var(--color-provisions-text-dark);
  margin: 0;
  line-height: 1.5;
  font-family: var(--font-family-heading);
  font-weight: normal;
}

/* Nutrition Info */
.nutrition-wrapper {
  position: relative;
  margin: 35px -40px 55px -40px;
  display: flex;
  flex-direction: column;
  align-items: center;
}

.nutrition-toggle {
  position: relative;
  z-index: 1;
  display: flex;
  gap: 0;
  background: #c25450;
  border-radius: 3px;
  margin-bottom: -1px;
  transform: translateY(14px);
  padding: 0 2px;
  overflow: hidden;
}

.nutrition-toggle__btn {
  margin: 4px 2px;
  padding: 4px 10px;
  font-family: var(--font-family-base);
  font-size: 12px;
  font-weight: 400;
  background: transparent;
  color: rgba(255, 255, 255, 0.8);
  border: none;
  border-radius: 3px;
  cursor: pointer;
  transition: all 0.15s ease;
}

.nutrition-toggle__btn:hover {
  color: white;
  background: rgba(255, 255, 255, 0.1);
}

.nutrition-toggle__btn--active {
  background: white;
  color: #c25450;
}

.nutrition-toggle__btn--active:hover {
  background: white;
  color: #c25450;
}

.nutrition-info {
  display: flex;
  justify-content: space-between;
  width: 100%;
  border-top: 1px solid var(--color-provisions-border);
  border-bottom: 1px solid var(--color-provisions-border);
}

.nutrition-info__item {
  display: flex;
  flex-direction: column;
  align-items: center;
  flex: 1;
  padding: 25px 0;
  border-right: 1px solid var(--color-provisions-border);
}

.nutrition-info__item:last-child {
  border-right: none;
}

.nutrition-info__value {
  font-family: var(--font-family-heading);
  font-size: 24px;
  font-weight: 600;
  color: var(--color-provisions-text-dark);
  line-height: 1.2;
}

.nutrition-info__label {
  font-family: var(--font-family-heading);
  font-size: 13px;
  font-weight: 400;
  color: var(--color-provisions-text-muted);
  margin-bottom: 4px;
}

/* Servings Adjuster */
.servings-adjuster {
  display: flex;
  align-items: center;
  gap: 15px;
  margin-bottom: 40px;
}

.servings-adjuster__controls {
  flex: 1 1 0;
  min-width: 0;
  display: flex;
  align-items: center;
  justify-content: center;
  height: 50px;
  border: 1px solid var(--color-provisions-text-dark);
  border-radius: 4px;
  background: transparent;
}

.servings-adjuster__btn {
  width: 40px;
  height: 40px;
  border: none;
  background: #c25450;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 28px;
  font-weight: bold;
  color: white;
  margin: 5px;
  border-radius: 4px;
  transition: opacity 0.15s;
}

.servings-adjuster__btn--minus {
  padding-bottom: 3px;
}

.servings-adjuster__btn:hover {
  background: #a8443f;
}

.servings-adjuster__value {
  flex: 1;
  text-align: center;
  font-size: 18px;
  font-family: var(--font-family-base);
  color: var(--color-provisions-text-dark);
}

.servings-adjuster__adjust-btn {
  flex: 1 1 0;
  min-width: 0;
  height: 50px;
  padding: 0;
  border: none;
  border-radius: 4px;
  background: #c25450;
  color: white;
  font-size: 18px;
  font-family: var(--font-family-base);
  font-weight: 500;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: opacity 0.15s;
}

.servings-adjuster__adjust-btn:hover {
  background: #a8443f;
}

.sparkle-icon {
  margin-left: 8px;
}

/* AI Disclaimer */
.ai-disclaimer {
  padding: 12px 16px;
  margin-bottom: 30px;
  background: #fff3cd;
  border: 1px solid #ffc107;
  border-radius: 4px;
  font-size: 14px;
  font-family: var(--font-family-base);
  color: #856404;
  line-height: 1.4;
}

.ai-disclaimer__text {
  margin: 0;
}

.ai-disclaimer__restore {
  display: inline-block;
  margin-top: 8px;
  color: #664d03;
  text-decoration: underline;
  cursor: pointer;
}

.ai-disclaimer__restore:hover {
  color: #3d2e02;
}

/* Recipe Sections */
.recipe-section {
  border-top: 1px solid var(--color-provisions-border);
  padding: 40px;
}

.recipe-section__title {
  font-family: var(--font-family-heading);
  font-size: inherit;
  font-weight: 600;
  margin: 0 0 15px 0;
  color: var(--color-provisions-text-dark);
}

/* Ingredients */
.ingredient-group {
  margin-bottom: 15px;
}

.ingredient-group:last-child {
  margin-bottom: 0;
}

.ingredient-group__name {
  font-size: inherit;
  font-weight: 600;
  color: var(--color-provisions-text-dark);
  margin: 30px 0 20px 0;
}

.ingredient-group:first-child .ingredient-group__name {
  margin-top: 0;
}

.ingredient-list {
  list-style: none;
  padding: 0;
  margin: 0;
}

.ingredient-item {
  font-size: inherit;
  color: var(--color-provisions-text-dark);
  line-height: 1.6;
  font-family: var(--font-family-heading);
}

.ingredient-item__amount {
  font-weight: 600;
  margin-right: 4px;
}

.ingredient-item__amount--flash {
  animation: amount-flash 0.6s ease-out;
}

@keyframes amount-flash {
  0% {
    color: var(--color-error);
  }
  100% {
    color: inherit;
  }
}

.ingredient-item__prep {
  color: var(--color-provisions-border);
}

.ingredient-item__equivalent {
  color: var(--color-provisions-border);
  font-style: italic;
}

.ingredient-item__optional {
  color: var(--color-provisions-border);
  font-style: italic;
}

/* Steps */
.recipe-steps {
  border-top: 1px solid var(--color-provisions-border);
  padding: 40px;
  padding-bottom: 1000px;
}

.edit-mode__preview-panel .recipe-steps,
.edit-mode__preview-panel .steps-list,
.edit-mode__preview-panel .step-item,
.edit-mode__preview-panel .step-item__text {
  background: none !important;
  background-color: transparent !important;
  border-top: none;
}

.edit-mode__preview-panel .recipe-steps {
  padding-bottom: 40px;
}

.recipe-steps__header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 20px;
}

.recipe-steps__header .recipe-section__title {
  margin-bottom: 0;
}

.step-images-toggle {
  display: flex;
  align-items: center;
  gap: 6px;
  padding: 6px 12px;
  background: var(--color-error);
  border: 1px solid var(--color-error);
  border-radius: 4px;
  font-family: var(--font-family-base);
  font-size: 13px;
  color: white;
  cursor: pointer;
  transition: all 0.15s;
}

.step-images-toggle:hover {
  background: var(--color-error-dark);
  border-color: var(--color-error-dark);
  color: white;
}

.step-images-toggle i {
  font-size: 14px;
}

.steps-list {
  display: flex;
  flex-direction: column;
  gap: 0;
}

.step-item {
  margin-bottom: 20px;
}

.step-item:last-child {
  margin-bottom: 0;
}

.step-section-heading {
  font-size: inherit;
  font-weight: 600;
  color: var(--color-provisions-text-dark);
  margin: 10px 0 20px 0;
}

.step-item:first-child .step-section-heading {
  margin-top: 10px;
}

.step-item__text {
  font-size: inherit;
  color: var(--color-provisions-text-dark);
  line-height: 1.6;
  font-family: var(--font-family-heading);
  margin: 0;
}

/* Step Images */
.step-image {
  margin: 30px -40px;
}

.step-image__wrapper {
  position: relative;
}

.step-image__img {
  width: 100%;
  display: block;
}

.step-image__ai-badge {
  position: absolute;
  bottom: 12px;
  right: 12px;
  width: 32px;
  height: auto;
  opacity: 0.25;
}

.step-image__caption {
  font-family: var(--font-family-base);
  font-size: 14px;
  font-weight: 400;
  color: var(--color-provisions-text-muted);
  text-align: center;
  margin: 0;
  padding: 8px 20px;
}

/* Responsive */
@media (max-width: 1200px) {
  .edit-mode__container {
    flex-direction: column;
    align-items: center;
  }

  .edit-mode__form-panel,
  .edit-mode__preview-panel {
    width: 100%;
    max-width: 600px;
  }

  .edit-mode__form-panel {
    border-left: none;
    border-right: none;
    border-bottom: 1px solid var(--color-provisions-border);
  }
}

@media (max-width: 1000px) {
  .recipe-info,
  .recipe-section,
  .recipe-steps {
    padding: 25px;
  }

  .recipe-steps {
    padding-bottom: 1000px;
  }

  .step-image {
    margin: 20px -25px;
  }

  .servings-adjuster {
    flex-direction: column;
    gap: 10px;
  }

  .servings-adjuster__controls,
  .servings-adjuster__adjust-btn {
    flex: none;
    width: 100%;
  }

  .nutrition-wrapper {
    margin: 25px -25px 45px -25px;
  }

  .nutrition-info__label {
    font-size: 11px;
  }

  .nutrition-info__value {
    font-size: 18px;
  }
}
</style>
