<script setup lang="ts">
import { ref, computed, watch, onMounted, nextTick } from 'vue'
import { useI18n } from 'vue-i18n'
import { useDataReferenceStore } from '@/stores/dataReferenceStore'
import type { Recipe, RecipeIngredientGroup, RecipeIngredientItem, RecipeStep } from '@/services/types'
import InputText from 'primevue/inputtext'
import InputNumber from 'primevue/inputnumber'
import Textarea from 'primevue/textarea'
import Select from 'primevue/select'
import MultiSelect from 'primevue/multiselect'
import Button from 'primevue/button'
import Checkbox from 'primevue/checkbox'

// Props & Emits
interface Props {
  modelValue?: Partial<Recipe> | null
  loading?: boolean
}

const props = withDefaults(defineProps<Props>(), {
  modelValue: null,
  loading: false
})

const emit = defineEmits<{
  'update:modelValue': [value: Partial<Recipe>]
  save: []
  cancel: []
  'import-text': []
  'import-url': []
}>()

// Composables
const { t } = useI18n()
const dataStore = useDataReferenceStore()

// Form state - matches backend Recipe model exactly
const formData = ref<Partial<Recipe>>({
  name: '',
  language: 'en',
  source_url: '',
  requires_precision: false,
  precision_reason: undefined,
  servings: {
    original: undefined,
    min: undefined,
    max: undefined
  },
  timing: {
    prep_minutes: undefined,
    cook_minutes: undefined,
    total_minutes: undefined
  },
  nutrition: undefined,
  aliases: [],
  dietary_tags: [],
  dish_types: [],
  cuisines: [],
  recipe_types: [],
  ingredient_groups: [
    {
      name: '',
      items: []
    }
  ],
  steps: [],
  equipment: [],
  admin_notes: ''
})

// Ingredient group helpers
function addIngredientGroup() {
  formData.value.ingredient_groups?.push({
    name: '',
    items: [
      {
        name: '',
        amount: '',
        unit: '',
        preparation: '',
        optional: false
      }
    ]
  })
}

function removeIngredientGroup(index: number) {
  if (formData.value.ingredient_groups && formData.value.ingredient_groups.length > 1) {
    const group = formData.value.ingredient_groups[index]
    const groupName = group?.name || t('forms.recipe.sections.ingredients')
    if (confirm(`Are you sure you want to remove the ingredient group "${groupName}"? This cannot be undone.`)) {
      formData.value.ingredient_groups.splice(index, 1)
    }
  }
}

function addIngredient(groupIndex: number) {
  const groups = formData.value.ingredient_groups
  if (groups && groups[groupIndex]) {
    groups[groupIndex].items.push({
      name: '',
      amount: '',
      unit: '',
      preparation: '',
      optional: false
    })
  }
}

function removeIngredient(groupIndex: number, ingredientIndex: number) {
  const groups = formData.value.ingredient_groups
  if (groups && groups[groupIndex]) {
    groups[groupIndex].items.splice(ingredientIndex, 1)
  }
}

// Step helpers
let nextStepId = 1
function addStep() {
  const currentOrder = (formData.value.steps?.length ?? 0) + 1
  formData.value.steps?.push({
    id: `step-${nextStepId++}`,
    order: currentOrder,
    instruction: ''
  })
}

function removeStep(index: number) {
  formData.value.steps?.splice(index, 1)
}

function moveStepUp(index: number) {
  const steps = formData.value.steps
  if (index > 0 && steps && steps[index - 1] && steps[index]) {
    const temp = steps[index - 1]!
    steps[index - 1] = steps[index]!
    steps[index] = temp
  }
}

function moveStepDown(index: number) {
  const steps = formData.value.steps
  if (steps && index < steps.length - 1 && steps[index] && steps[index + 1]) {
    const temp = steps[index]
    steps[index] = steps[index + 1]!
    steps[index + 1] = temp!
  }
}

// Equipment - simple string array
const equipmentInput = ref('')
function addEquipment() {
  if (equipmentInput.value.trim() && formData.value.equipment) {
    formData.value.equipment.push(equipmentInput.value.trim())
    equipmentInput.value = ''
  }
}

function removeEquipment(index: number) {
  formData.value.equipment?.splice(index, 1)
}

// Aliases
const aliasInput = ref('')
function addAlias() {
  if (aliasInput.value.trim() && formData.value.aliases) {
    formData.value.aliases.push(aliasInput.value.trim())
    aliasInput.value = ''
  }
}

function removeAlias(index: number) {
  formData.value.aliases?.splice(index, 1)
}

// Dropdown options
const languageOptions = [
  { label: 'English', value: 'en' },
  { label: '日本語', value: 'ja' },
  { label: '한국어', value: 'ko' },
  { label: '繁體中文', value: 'zh-tw' },
  { label: '简体中文', value: 'zh-cn' },
  { label: 'Español', value: 'es' },
  { label: 'Français', value: 'fr' }
]

const precisionReasonOptions = [
  { label: t('forms.recipe.precisionReasons.baking'), value: 'baking' },
  { label: t('forms.recipe.precisionReasons.confectionery'), value: 'confectionery' },
  { label: t('forms.recipe.precisionReasons.fermentation'), value: 'fermentation' },
  { label: t('forms.recipe.precisionReasons.molecular'), value: 'molecular' }
]

// Flag to prevent recursive updates
const isUpdatingFromProp = ref(false)

// Validation
const validationErrors = ref<string[]>([])
const showValidationErrors = ref(false)

const isValid = computed(() => {
  validationErrors.value = []

  // Required: Recipe name
  if (!formData.value.name || formData.value.name.trim().length === 0) {
    validationErrors.value.push('Recipe name is required')
  }

  // Required: Language
  if (!formData.value.language) {
    validationErrors.value.push('Language is required')
  }

  // Required: Servings validation
  if (!formData.value.servings ||
      formData.value.servings.original == null ||
      formData.value.servings.original <= 0) {
    validationErrors.value.push('Servings must be greater than 0')
  }

  // Required: At least one ingredient group with name and items
  if (!formData.value.ingredient_groups || formData.value.ingredient_groups.length === 0) {
    validationErrors.value.push('At least one ingredient group is required')
  } else {
    // Each ingredient group must have a name
    for (let i = 0; i < formData.value.ingredient_groups.length; i++) {
      const group = formData.value.ingredient_groups[i]
      if (!group || !group.name || group.name.trim().length === 0) {
        validationErrors.value.push(`Ingredient group ${i + 1} must have a name`)
      }

      // Each ingredient must have a name
      if (group?.items && group.items.length > 0) {
        for (let j = 0; j < group.items.length; j++) {
          const item = group.items[j]
          if (!item || !item.name || item.name.trim().length === 0) {
            validationErrors.value.push(`Ingredient ${j + 1} in group "${group.name || i + 1}" must have a name`)
          }
        }
      }
    }

    // At least one group must have ingredients
    if (!formData.value.ingredient_groups.some(g => g?.items && g.items.length > 0)) {
      validationErrors.value.push('At least one ingredient is required')
    }
  }

  // Required: At least one step with instructions
  if (!formData.value.steps || formData.value.steps.length === 0) {
    validationErrors.value.push('At least one step is required')
  } else {
    // Each step must have instructions
    for (let i = 0; i < formData.value.steps.length; i++) {
      const step = formData.value.steps[i]
      if (!step || !step.instruction || step.instruction.trim().length === 0) {
        validationErrors.value.push(`Step ${i + 1} must have instructions`)
      }
    }
  }

  // Required: Timing fields must be provided and non-negative
  if (formData.value.timing?.prep_minutes == null) {
    validationErrors.value.push('Prep time is required')
  } else if (formData.value.timing.prep_minutes < 0) {
    validationErrors.value.push('Prep time cannot be negative')
  }

  if (formData.value.timing?.cook_minutes == null) {
    validationErrors.value.push('Cook time is required')
  } else if (formData.value.timing.cook_minutes < 0) {
    validationErrors.value.push('Cook time cannot be negative')
  }

  if (formData.value.timing?.total_minutes == null) {
    validationErrors.value.push('Total time is required')
  } else if (formData.value.timing.total_minutes < 0) {
    validationErrors.value.push('Total time cannot be negative')
  }

  // Optional: Precision reason validation
  if (formData.value.requires_precision && !formData.value.precision_reason) {
    validationErrors.value.push('Precision reason is required when precision is enabled')
  }

  return validationErrors.value.length === 0
})

// Watch for prop changes (only update if prop has actual data)
watch(() => props.modelValue, (newValue) => {
  if (newValue && Object.keys(newValue).length > 0) {
    isUpdatingFromProp.value = true
    formData.value = { ...newValue }
    // Initialize nested objects if undefined (but keep empty, no defaults)
    if (!formData.value.servings) {
      formData.value.servings = {
        original: undefined,
        min: undefined,
        max: undefined
      }
    }
    if (!formData.value.timing) {
      formData.value.timing = {
        prep_minutes: undefined,
        cook_minutes: undefined,
        total_minutes: undefined
      }
    }
    // Initialize arrays if undefined
    if (!formData.value.ingredient_groups || formData.value.ingredient_groups.length === 0) {
      formData.value.ingredient_groups = [{
        name: '',
        items: []
      }]
    }
    if (!formData.value.steps) formData.value.steps = []
    if (!formData.value.equipment) formData.value.equipment = []
    if (!formData.value.aliases) formData.value.aliases = []
    if (!formData.value.dietary_tags) formData.value.dietary_tags = []
    if (!formData.value.dish_types) formData.value.dish_types = []
    if (!formData.value.cuisines) formData.value.cuisines = []
    if (!formData.value.recipe_types) formData.value.recipe_types = []

    // Reset flag on next tick to allow subsequent user changes to emit
    nextTick(() => {
      isUpdatingFromProp.value = false
    })
  }
}, { immediate: true })

// Watch for form data changes and emit to parent for live preview
watch(formData, (newValue) => {
  // Don't emit if we're updating from prop to prevent infinite loop
  if (!isUpdatingFromProp.value) {
    emit('update:modelValue', newValue)
  }
}, { deep: true, flush: 'post' })

// Methods
function validateForm(): boolean {
  if (!isValid.value) {
    showValidationErrors.value = true
    return false
  }
  showValidationErrors.value = false
  return true
}

function handleSave() {
  if (!isValid.value) {
    showValidationErrors.value = true
    return
  }
  showValidationErrors.value = false
  emit('update:modelValue', formData.value)
  emit('save')
}

function handleCancel() {
  emit('cancel')
}

// Expose validation for parent component
defineExpose({
  validateForm,
  isValid
})

// Lifecycle
onMounted(async () => {
  // Fetch data references if not already loaded
  if (dataStore.dietaryTags.length === 0 ||
      dataStore.dishTypes.length === 0 ||
      dataStore.cuisines.length === 0 ||
      dataStore.recipeTypes.length === 0) {
    await dataStore.fetchAll()
  }

  // Initialize with at least one ingredient and one step if empty
  if (formData.value.ingredient_groups && formData.value.ingredient_groups.length > 0) {
    const firstGroup = formData.value.ingredient_groups[0]
    if (firstGroup && firstGroup.items.length === 0) {
      addIngredient(0)
    }
  }
  if (formData.value.steps && formData.value.steps.length === 0) {
    addStep()
  }
})
</script>

<template>
  <div class="recipe-form">
    <form @submit.prevent="handleSave">
      <!-- Validation Error Messages -->
      <div v-if="showValidationErrors && validationErrors.length > 0" role="alert" class="recipe-form__validation-errors">
        <div class="recipe-form__error-header">
          <i class="pi pi-exclamation-circle"></i>
          <span>Please fix the following errors:</span>
        </div>
        <ul class="recipe-form__error-list">
          <li v-for="(error, index) in validationErrors" :key="index">{{ error }}</li>
        </ul>
      </div>

      <!-- Import Buttons -->
      <div class="recipe-form__import-buttons">
        <Button
          type="button"
          :label="$t('admin.recipes.importDialog.button')"
          icon="pi pi-file-import"
          @click="emit('import-text')"
        />
        <Button
          type="button"
          :label="$t('admin.recipes.urlImportDialog.button')"
          icon="pi pi-link"
          @click="emit('import-url')"
        />
        <Button
          type="button"
          label="Import from Image"
          icon="pi pi-image"
          disabled
        />
      </div>

      <hr />

      <!-- Basic Information -->
      <section class="recipe-form__section">
        <h2 class="recipe-form__section-title">{{ $t('forms.recipe.sections.basicInfo') }}</h2>

        <div class="recipe-form__field recipe-form__field--wide">
          <label for="name" class="recipe-form__label required">
            {{ $t('forms.recipe.name') }}
          </label>
          <InputText
            id="name"
            v-model="formData.name"
            :placeholder="$t('forms.recipe.namePlaceholder')"
            class="recipe-form__input"
            required
          />
        </div>

        <div class="recipe-form__field recipe-form__field--alias">
          <label for="aliases" class="recipe-form__label">
            {{ $t('forms.recipe.aliases') }}
          </label>
          <div class="recipe-form__input-with-button">
            <InputText
              id="aliases"
              v-model="aliasInput"
              :placeholder="$t('forms.recipe.aliasesPlaceholder')"
              class="recipe-form__input"
              @keydown.enter.prevent="addAlias"
            />
            <Button
              type="button"
              :label="$t('common.buttons.add')"
              severity="success"
              @click="addAlias"
            />
          </div>
          <small class="recipe-form__help-text">{{ $t('forms.recipe.aliasesHint') }}</small>
        </div>

        <div v-if="formData.aliases && formData.aliases.length > 0" class="recipe-form__tags">
          <span
            v-for="(alias, index) in formData.aliases"
            :key="index"
            class="recipe-form__tag"
          >
            {{ alias }}
            <button type="button" @click="removeAlias(index)">×</button>
          </span>
        </div>

        <div class="recipe-form__field">
          <label for="source_url" class="recipe-form__label">
            {{ $t('forms.recipe.sourceUrl') }}
          </label>
          <InputText
            id="source_url"
            v-model="formData.source_url"
            :placeholder="$t('forms.recipe.sourceUrlPlaceholder')"
            class="recipe-form__input"
          />
        </div>

        <div class="recipe-form__field recipe-form__field--medium">
          <label for="language" class="recipe-form__label required">
            {{ $t('forms.recipe.language') }}
          </label>
          <Select
            id="language"
            v-model="formData.language"
            :options="languageOptions"
            optionLabel="label"
            optionValue="value"
            :placeholder="$t('forms.recipe.languagePlaceholder')"
            class="recipe-form__input"
          />
        </div>

        <div class="recipe-form__field">
          <div class="recipe-form__checkbox-field">
            <Checkbox
              id="requires_precision"
              v-model="formData.requires_precision"
              :binary="true"
            />
            <label for="requires_precision" class="recipe-form__label-inline">
              {{ $t('forms.recipe.requiresPrecision') }}
            </label>
          </div>
          <small class="recipe-form__help-text">{{ $t('forms.recipe.requiresPrecisionHint') }}</small>
        </div>

        <div v-if="formData.requires_precision" class="recipe-form__field recipe-form__field--medium">
          <label for="precision_reason" class="recipe-form__label required">
            {{ $t('forms.recipe.precisionReason') }}
          </label>
          <Select
            id="precision_reason"
            v-model="formData.precision_reason"
            :options="precisionReasonOptions"
            optionLabel="label"
            optionValue="value"
            :placeholder="$t('forms.recipe.precisionReasonPlaceholder')"
            class="recipe-form__input"
          />
        </div>
      </section>

      <hr/>

      <!-- Tags & Classification -->
      <section class="recipe-form__section">
        <h2 class="recipe-form__section-title">{{ $t('forms.recipe.sections.classification') }}</h2>

        <div class="recipe-form__field">
          <label for="dietary_tags" class="recipe-form__label">
            {{ $t('forms.recipe.dietaryTags') }}
          </label>
          <MultiSelect
            id="dietary_tags"
            v-model="formData.dietary_tags"
            :options="dataStore.dietaryTags"
            optionLabel="display_name"
            optionValue="key"
            :placeholder="$t('forms.recipe.dietaryTagsPlaceholder')"
            class="recipe-form__input"
            display="chip"
            filter
          />
        </div>

        <div class="recipe-form__field">
          <label for="cuisines" class="recipe-form__label">
            {{ $t('forms.recipe.cuisines') }}
          </label>
          <MultiSelect
            id="cuisines"
            v-model="formData.cuisines"
            :options="dataStore.cuisines"
            optionLabel="display_name"
            optionValue="key"
            :placeholder="$t('forms.recipe.cuisinesPlaceholder')"
            class="recipe-form__input"
            display="chip"
            filter
          />
        </div>

        <div class="recipe-form__field">
          <label for="dish_types" class="recipe-form__label">
            {{ $t('forms.recipe.dishTypes') }}
          </label>
          <MultiSelect
            id="dish_types"
            v-model="formData.dish_types"
            :options="dataStore.dishTypes"
            optionLabel="display_name"
            optionValue="key"
            :placeholder="$t('forms.recipe.dishTypesPlaceholder')"
            class="recipe-form__input"
            display="chip"
            filter
          />
        </div>

        <div class="recipe-form__field">
          <label for="recipe_types" class="recipe-form__label">
            {{ $t('forms.recipe.recipeTypes') }}
          </label>
          <MultiSelect
            id="recipe_types"
            v-model="formData.recipe_types"
            :options="dataStore.recipeTypes"
            optionLabel="display_name"
            optionValue="key"
            :placeholder="$t('forms.recipe.recipeTypesPlaceholder')"
            class="recipe-form__input"
            display="chip"
            filter
          />
        </div>
      </section>

      <hr/>

      <!-- Servings & Timing -->
      <section class="recipe-form__section">
        <h2 class="recipe-form__section-title">{{ $t('forms.recipe.sections.servings') }} & {{ $t('forms.recipe.sections.timing') }}</h2>

        <div class="recipe-form__row">
          <div class="recipe-form__field recipe-form__field--one-third">
            <label for="servings_original" class="recipe-form__label required">
              {{ $t('forms.recipe.servings.label') }}
            </label>
            <InputNumber
              id="servings_original"
              v-model="formData.servings!.original"
              :min="1"
              :max="100"
              class="recipe-form__input"
              required
            />
            <small class="recipe-form__help-text">{{ $t('forms.recipe.servings.hint') }}</small>
          </div>
        </div>

        <div class="recipe-form__row">
          <div class="recipe-form__field recipe-form__field--narrow">
            <label for="timing_prep_minutes" class="recipe-form__label required">
              {{ $t('forms.recipe.prepTime') }}
            </label>
            <InputNumber
              id="timing_prep_minutes"
              v-model="formData.timing!.prep_minutes"
              :min="0"
              :max="1440"
              suffix=" min"
              :placeholder="'e.g. 15'"
              class="recipe-form__input"
            />
            <small class="recipe-form__help-text">{{ $t('forms.recipe.prepTimeHint') }}</small>
          </div>

          <div class="recipe-form__field recipe-form__field--narrow">
            <label for="timing_cook_minutes" class="recipe-form__label required">
              {{ $t('forms.recipe.cookTime') }}
            </label>
            <InputNumber
              id="timing_cook_minutes"
              v-model="formData.timing!.cook_minutes"
              :min="0"
              :max="1440"
              suffix=" min"
              :placeholder="'e.g. 30'"
              class="recipe-form__input"
            />
            <small class="recipe-form__help-text">{{ $t('forms.recipe.cookTimeHint') }}</small>
          </div>

          <div class="recipe-form__field recipe-form__field--narrow">
            <label for="timing_total_minutes" class="recipe-form__label required">
              {{ $t('forms.recipe.totalTime') }}
            </label>
            <InputNumber
              id="timing_total_minutes"
              v-model="formData.timing!.total_minutes"
              :min="0"
              :max="1440"
              suffix=" min"
              :placeholder="'e.g. 45'"
              class="recipe-form__input"
            />
            <small class="recipe-form__help-text">{{ $t('forms.recipe.totalTimeHint') }}</small>
          </div>
        </div>
      </section>

      <hr/>

      <!-- Equipment -->
      <section class="recipe-form__section">
        <h2 class="recipe-form__section-title">{{ $t('forms.recipe.sections.equipment') }}</h2>

        <div class="recipe-form__field">
          <div class="recipe-form__input-with-button">
            <InputText
              id="equipment"
              v-model="equipmentInput"
              :placeholder="$t('forms.recipe.equipmentPlaceholder')"
              class="recipe-form__input"
              @keydown.enter.prevent="addEquipment"
            />
            <Button
              type="button"
              :label="$t('common.buttons.add')"
              severity="success"
              @click="addEquipment"
            />
          </div>
          <small class="recipe-form__help-text">
            {{ $t('forms.recipe.equipmentHint') }}
          </small>
        </div>

        <div v-if="formData.equipment && formData.equipment.length > 0" class="recipe-form__tags">
          <span
            v-for="(item, index) in formData.equipment"
            :key="index"
            class="recipe-form__tag"
          >
            {{ item }}
            <button type="button" @click="removeEquipment(index)">×</button>
          </span>
        </div>
      </section>

      <hr/>

      <!-- Ingredients -->
      <h2 class="recipe-form__major-section-title">{{ $t('forms.recipe.sections.ingredients') }}</h2>

      <!-- Ingredient Groups -->
      <section
        v-for="(group, groupIndex) in formData.ingredient_groups"
        :key="groupIndex"
        class="recipe-form__section recipe-form__ingredient-group"
      >
        <div class="recipe-form__section-header">
          <h2 class="recipe-form__section-title">
            {{ group.name || $t('forms.recipe.sections.ingredients') }}
          </h2>
          <Button
            v-if="formData.ingredient_groups!.length > 1"
            type="button"
            icon="pi pi-trash"
            :label="$t('forms.recipe.removeGroup')"
            severity="danger"
            size="small"
            @click="removeIngredientGroup(groupIndex)"
            class="recipe-form__remove-group-btn"
          />
        </div>

        <div class="recipe-form__field">
          <label :for="'group-name-' + groupIndex" class="recipe-form__label required">
            {{ $t('forms.recipe.groupName') }}
          </label>
          <InputText
            :id="'group-name-' + groupIndex"
            v-model="group.name"
            :placeholder="$t('forms.recipe.groupNamePlaceholder')"
            class="recipe-form__input"
          />
        </div>

        <div class="recipe-form__ingredients-grid">
          <div
            v-for="(item, itemIndex) in group.items"
            :key="itemIndex"
            class="recipe-form__ingredient"
          >
            <div class="recipe-form__ingredient-row recipe-form__ingredient-row--main">
              <div class="recipe-form__field">
                <label :for="'ingredient-name-' + groupIndex + '-' + itemIndex" class="recipe-form__label required">
                  {{ $t('forms.recipe.ingredientName') }}
                </label>
                <InputText
                  :id="'ingredient-name-' + groupIndex + '-' + itemIndex"
                  v-model="item.name"
                  :placeholder="$t('forms.recipe.ingredientNamePlaceholder')"
                  class="recipe-form__input"
                  required
                />
              </div>

              <div class="recipe-form__field">
                <label :for="'ingredient-amount-' + groupIndex + '-' + itemIndex" class="recipe-form__label">
                  {{ $t('forms.recipe.ingredientAmount') }}
                </label>
                <InputText
                  :id="'ingredient-amount-' + groupIndex + '-' + itemIndex"
                  v-model="item.amount"
                  :placeholder="$t('forms.recipe.ingredientAmountPlaceholder')"
                  class="recipe-form__input"
                />
              </div>

              <div class="recipe-form__field">
                <label :for="'ingredient-unit-' + groupIndex + '-' + itemIndex" class="recipe-form__label">
                  {{ $t('forms.recipe.ingredientUnit') }}
                </label>
                <InputText
                  :id="'ingredient-unit-' + groupIndex + '-' + itemIndex"
                  v-model="item.unit"
                  :placeholder="$t('forms.recipe.ingredientUnitPlaceholder')"
                  class="recipe-form__input"
                />
              </div>
            </div>

            <div class="recipe-form__ingredient-row recipe-form__ingredient-row--notes">
              <div class="recipe-form__field">
                <label :for="'ingredient-notes-' + groupIndex + '-' + itemIndex" class="recipe-form__label">
                  {{ $t('forms.recipe.ingredientNotes') }}
                </label>
                <InputText
                  :id="'ingredient-notes-' + groupIndex + '-' + itemIndex"
                  v-model="item.preparation"
                  :placeholder="$t('forms.recipe.ingredientNotesPlaceholder')"
                  class="recipe-form__input"
                />
              </div>
            </div>

            <div class="recipe-form__ingredient-row recipe-form__ingredient-row--footer">
              <label
                :for="'ingredient-optional-' + groupIndex + '-' + itemIndex"
                class="recipe-form__optional-box"
                @click="item.optional = !item.optional"
              >
                <Checkbox
                  :id="'ingredient-optional-' + groupIndex + '-' + itemIndex"
                  v-model="item.optional"
                  :binary="true"
                />
                <span class="recipe-form__optional-label">
                  {{ $t('forms.recipe.ingredientOptional') }}
                </span>
              </label>

              <Button
                v-if="group.items?.length > 1"
                type="button"
                icon="pi pi-trash"
                severity="danger"
                size="small"
                text
                @click="removeIngredient(groupIndex, itemIndex)"
              />
            </div>
          </div>
        </div>

        <Button
          type="button"
          :label="$t('forms.recipe.addIngredient')"
          icon="pi pi-plus"
          severity="success"
          @click="addIngredient(groupIndex)"
        />
      </section>

      <div class="recipe-form__add-group-wrapper">
        <Button
          type="button"
          :label="$t('forms.recipe.addGroup')"
          icon="pi pi-plus"
          severity="success"
          @click="addIngredientGroup"
        />
      </div>

          <hr/>

      <!-- Steps -->
      <section class="recipe-form__section">
        <h2 class="recipe-form__section-title">{{ $t('forms.recipe.sections.steps') }}</h2>

        <div
          v-for="(step, index) in formData.steps"
          :key="step.id"
          class="recipe-form__step"
        >
          <div class="recipe-form__step-header">
            <span class="recipe-form__step-number">{{ $t('forms.recipe.step') }} {{ index + 1 }}</span>
            <div class="recipe-form__step-actions">
              <Button
                type="button"
                icon="pi pi-arrow-up"
                severity="secondary"
                size="small"
                text
                :disabled="index === 0"
                @click="moveStepUp(index)"
              />
              <Button
                type="button"
                icon="pi pi-arrow-down"
                severity="secondary"
                size="small"
                text
                :disabled="index === formData.steps!.length - 1"
                @click="moveStepDown(index)"
              />
              <Button
                v-if="formData.steps?.length > 1"
                type="button"
                icon="pi pi-trash"
                severity="danger"
                size="small"
                text
                @click="removeStep(index)"
              />
            </div>
          </div>
          <Textarea
            v-model="step.instruction"
            :placeholder="$t('forms.recipe.stepInstruction')"
            rows="3"
            class="recipe-form__step-instruction"
            required
          />
        </div>

        <Button
          type="button"
          :label="$t('forms.recipe.addStep')"
          icon="pi pi-plus"
          severity="success"
          class="recipe-form__add-step-button"
          @click="addStep"
        />
      </section>

      <hr/>

      <!-- Admin Notes -->
      <section class="recipe-form__section">
        <h2 class="recipe-form__section-title">{{ $t('forms.recipe.sections.adminNotes') }}</h2>

        <div class="recipe-form__field">
          <label for="admin_notes" class="recipe-form__label">
            {{ $t('forms.recipe.adminNotes') }}
          </label>
          <Textarea
            id="admin_notes"
            v-model="formData.admin_notes"
            :placeholder="$t('forms.recipe.adminNotesPlaceholder')"
            rows="4"
            class="recipe-form__input"
          />
          <small class="recipe-form__help-text">{{ $t('forms.recipe.adminNotesHint') }}</small>
        </div>
      </section>
    </form>
  </div>
</template>

<style>
  .split-panel-container {
    padding: 0 !important;
  }
</style>

<style scoped>

.recipe-form__field--alias {
  margin-bottom: 5px !important;
}

.recipe-form {
  background: var(--color-surface);
  border-radius: var(--border-radius-lg);
}

.recipe-form__validation-errors {
  background-color: #fee;
  border: 1px solid #fcc;
  border-radius: var(--border-radius-md);
  padding: 16px;
  margin-bottom: 20px;
  color: #d32f2f;
}

.recipe-form__error-header {
  display: flex;
  align-items: center;
  gap: 8px;
  font-weight: 600;
  margin-bottom: 8px;
}

.recipe-form__error-header i {
  font-size: 20px;
}

.recipe-form__error-list {
  list-style: disc;
  margin: 0;
  padding-left: 24px;
}

.recipe-form__error-list li {
  margin: 4px 0;
  font-size: 14px;
}

hr {
  margin: 40px 0;
}

.recipe-form__major-section-title {
  font-size: var(--font-size-2xl);
  font-weight: var(--font-weight-bold);
  color: var(--color-text);
  margin-bottom: var(--spacing-lg);
  margin-top: 0;
}

.recipe-form__section:last-of-type {
  border-bottom: none;
  padding-bottom: 0;
}

/* Normalize input heights - make selects and text inputs the same height */
.recipe-form__input :deep(.p-inputtext),
.recipe-form__input :deep(.p-dropdown),
.recipe-form__input :deep(.p-multiselect) {
  min-height: 42px;
  height: 42px;
}

.recipe-form__input :deep(.p-inputnumber-input) {
  min-height: 42px;
  height: 42px;
}

.recipe-form__ingredient-group {
  background: var(--color-background);
  border: 1px solid var(--color-border);
  border-radius: var(--border-radius-lg);
  padding: var(--spacing-xl);
  margin-bottom: var(--spacing-xl);
}

.recipe-form__section-title {
  font-size: var(--font-size-xl);
  font-weight: var(--font-weight-semibold);
  color: var(--color-text);
  margin-bottom: var(--spacing-lg);
}

.recipe-form__import-buttons {
  display: grid;
  grid-template-columns: 1fr 1fr 1fr;
  gap: var(--spacing-md);
  margin-bottom: var(--spacing-lg);
}

.recipe-form__add-step-button {
  width: 100%;
  margin-top: var(--spacing-sm);
}

.recipe-form__section-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: var(--spacing-md);
}

.recipe-form__field {
  margin-bottom: var(--spacing-lg);
}

.recipe-form__field--medium {
  max-width: 350px;
}

.recipe-form__field--one-third {
  max-width: 280px;
}

.recipe-form__label {
  display: block;
  font-size: var(--font-size-sm);
  font-weight: var(--font-weight-medium);
  color: var(--color-text);
  margin-bottom: var(--spacing-xs);
}

.recipe-form__label.required::after {
  content: ' *';
  color: var(--color-error);
}

.recipe-form__label-inline {
  font-size: var(--font-size-sm);
  font-weight: var(--font-weight-medium);
  color: var(--color-text);
  margin-left: var(--spacing-sm);
}

.recipe-form__input {
  width: 100%;
}

.recipe-form__row {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: var(--spacing-md);
}

.recipe-form__help-text {
  display: block;
  font-size: var(--font-size-xs);
  color: var(--color-text-muted);
  margin-top: var(--spacing-xs);
}

.recipe-form__checkbox-field {
  display: flex;
  align-items: center;
  gap: var(--spacing-sm);
}

.recipe-form__input-with-button {
  display: flex;
  gap: var(--spacing-sm);
}

.recipe-form__input-with-button :deep(.p-button) {
  white-space: nowrap;
  flex-shrink: 0;
}

.recipe-form__tags {
  display: flex;
  flex-wrap: wrap;
  gap: var(--spacing-sm);
  margin-bottom: var(--spacing-lg);
}

.recipe-form__tag {
  display: inline-flex;
  align-items: center;
  gap: var(--spacing-xs);
  padding: var(--spacing-xs) var(--spacing-sm);
  background: var(--color-primary);
  color: var(--color-white);
  border-radius: var(--border-radius-sm);
  font-size: var(--font-size-sm);
}

.recipe-form__tag button {
  background: none;
  border: none;
  color: var(--color-white);
  font-size: var(--font-size-lg);
  font-weight: var(--font-weight-bold);
  cursor: pointer;
  padding: 0;
  line-height: 1;
  opacity: 0.9;
  transition: opacity 0.2s;
}

.recipe-form__tag button:hover {
  opacity: 1;
}

.recipe-form__ingredients-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: var(--spacing-md);
  margin-bottom: var(--spacing-md);
}

.recipe-form__ingredient {
  background-color: var(--color-gray-100);
  padding: var(--spacing-lg);
  border-radius: var(--border-radius-md);
}

.recipe-form__add-group-wrapper {
  margin-bottom: var(--spacing-2xl);
}

.recipe-form__ingredient-row {
  display: grid;
  gap: var(--spacing-md);
  margin-bottom: var(--spacing-sm);
}

.recipe-form__ingredient-row--main {
  grid-template-columns: 2fr 1fr 1fr;
  align-items: flex-end;
}

.recipe-form__ingredient-row--notes {
  grid-template-columns: 1fr;
  margin-bottom: 0;
}

.recipe-form__ingredient-row--footer {
  margin-top: var(--spacing-md);
  grid-template-columns: 1fr 2fr;
  margin-bottom: 0;
  align-items: center;
}

.recipe-form__optional-box {
  background: white;
  display: flex;
  align-items: center;
  gap: var(--spacing-sm);
  padding: var(--spacing-sm) var(--spacing-md);
  border: 1px solid var(--color-border);
  border-radius: var(--border-radius-md);
  cursor: pointer;
  transition: all 0.2s;
  user-select: none;
}

.recipe-form__optional-box:hover {
  border-color: var(--color-border-dark);
  background-color: var(--color-gray-50);
}

.recipe-form__optional-label {
  font-size: var(--font-size-sm);
  color: var(--color-text);
  white-space: nowrap;
}

.recipe-form__ingredient-row .recipe-form__field {
  margin-bottom: 0;
}

/* Adjust PrimeVue input padding in ingredient rows */
.recipe-form__ingredient-row :deep(.p-inputtext) {
  padding: 0.5rem 0.75rem;
}

.recipe-form__step {
  padding: 0;
  background: var(--color-background);
  border-radius: var(--border-radius-md);
  margin-bottom: var(--spacing-md);
}

.recipe-form__step-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: var(--spacing-sm);
}

.recipe-form__step-number {
  font-weight: var(--font-weight-semibold);
  color: var(--color-text);
}

.recipe-form__step-actions {
  display: flex;
  gap: var(--spacing-xs);
}

.recipe-form__step-instruction {
  width: 100%;
}

.recipe-form__remove-group-btn :deep(.p-button-label) {
  color: white;
}

/* Mobile responsive */
@media (max-width: 768px) {
  .recipe-form__row {
    grid-template-columns: 1fr;
  }

  .recipe-form__ingredients-grid {
    grid-template-columns: 1fr;
  }

  .recipe-form__ingredient-row {
    grid-template-columns: 1fr;
  }
}
</style>
