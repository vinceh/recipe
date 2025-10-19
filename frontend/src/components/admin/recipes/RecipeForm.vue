<script setup lang="ts">
import { ref, computed, watch, onMounted } from 'vue'
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
    original: 4,
    min: 1,
    max: 12
  },
  timing: {
    prep_minutes: 0,
    cook_minutes: 0,
    total_minutes: 0
  },
  nutrition: undefined,
  aliases: [],
  dietary_tags: [],
  dish_types: [],
  cuisines: [],
  recipe_types: [],
  ingredient_groups: [
    {
      name: '', // Start with empty name to force user to fill it
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
    items: []
  })
}

function removeIngredientGroup(index: number) {
  if (formData.value.ingredient_groups && formData.value.ingredient_groups.length > 1) {
    formData.value.ingredient_groups.splice(index, 1)
  }
}

function addIngredient(groupIndex: number) {
  const groups = formData.value.ingredient_groups
  if (groups && groups[groupIndex]) {
    groups[groupIndex].items.push({
      name: '',
      amount: '',
      unit: '',
      notes: '',
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

// Step helpers - backend expects {id, instructions: {lang: "text"}}
let nextStepId = 1
function addStep() {
  const currentLang = formData.value.language || 'en'
  formData.value.steps?.push({
    id: nextStepId++,
    instructions: {
      [currentLang]: ''
    }
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

// Validation
const validationErrors = ref<string[]>([])

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
      !formData.value.servings.original ||
      formData.value.servings.original <= 0) {
    validationErrors.value.push('Original servings must be greater than 0')
  }

  if (formData.value.servings.min && formData.value.servings.min <= 0) {
    validationErrors.value.push('Minimum servings must be greater than 0')
  }

  if (formData.value.servings.max && formData.value.servings.max <= 0) {
    validationErrors.value.push('Maximum servings must be greater than 0')
  }

  if (formData.value.servings.min && formData.value.servings.max &&
      formData.value.servings.min > formData.value.servings.max) {
    validationErrors.value.push('Minimum servings cannot exceed maximum servings')
  }

  // Required: At least one ingredient group with name and items
  if (!formData.value.ingredient_groups || formData.value.ingredient_groups.length === 0) {
    validationErrors.value.push('At least one ingredient group is required')
  } else {
    // Each ingredient group must have a name
    for (let i = 0; i < formData.value.ingredient_groups.length; i++) {
      const group = formData.value.ingredient_groups[i]
      if (!group.name || group.name.trim().length === 0) {
        validationErrors.value.push(`Ingredient group ${i + 1} must have a name`)
      }

      // Each ingredient must have a name
      if (group.items && group.items.length > 0) {
        for (let j = 0; j < group.items.length; j++) {
          if (!group.items[j].name || group.items[j].name.trim().length === 0) {
            validationErrors.value.push(`Ingredient ${j + 1} in group "${group.name || i + 1}" must have a name`)
          }
        }
      }
    }

    // At least one group must have ingredients
    if (!formData.value.ingredient_groups.some(g => g.items && g.items.length > 0)) {
      validationErrors.value.push('At least one ingredient is required')
    }
  }

  // Required: At least one step with instructions
  if (!formData.value.steps || formData.value.steps.length === 0) {
    validationErrors.value.push('At least one step is required')
  } else {
    // Each step must have instructions in the current language
    for (let i = 0; i < formData.value.steps.length; i++) {
      const step = formData.value.steps[i]
      const lang = formData.value.language || 'en'
      if (!step.instructions || !step.instructions[lang] ||
          step.instructions[lang].trim().length === 0) {
        validationErrors.value.push(`Step ${i + 1} must have instructions`)
      }
    }
  }

  // Optional: Timing validation (if provided, must be non-negative)
  if (formData.value.timing) {
    if (formData.value.timing.prep_minutes < 0) {
      validationErrors.value.push('Prep time cannot be negative')
    }
    if (formData.value.timing.cook_minutes < 0) {
      validationErrors.value.push('Cook time cannot be negative')
    }
    if (formData.value.timing.total_minutes < 0) {
      validationErrors.value.push('Total time cannot be negative')
    }
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
    formData.value = { ...newValue }
    // Initialize nested objects if undefined
    if (!formData.value.servings) {
      formData.value.servings = {
        original: 4,
        min: 1,
        max: 12
      }
    }
    if (!formData.value.timing) {
      formData.value.timing = {
        prep_minutes: 0,
        cook_minutes: 0,
        total_minutes: 0
      }
    }
    // Initialize arrays if undefined
    if (!formData.value.ingredient_groups || formData.value.ingredient_groups.length === 0) {
      formData.value.ingredient_groups = [{
        name: t('forms.recipe.ingredientGroups.main'),
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
  }
}, { immediate: true })

// Methods
function handleSave() {
  console.log('Form data being sent:', JSON.stringify(formData.value, null, 2))
  emit('update:modelValue', formData.value)
  emit('save')
}

function handleCancel() {
  emit('cancel')
}

// Lifecycle
onMounted(async () => {
  console.log('RecipeForm mounted - checking data stores...')

  // Fetch data references if not already loaded
  if (dataStore.dietaryTags.length === 0 ||
      dataStore.dishTypes.length === 0 ||
      dataStore.cuisines.length === 0 ||
      dataStore.recipeTypes.length === 0) {
    console.log('Fetching data references...')
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
      <!-- Basic Information -->
      <section class="recipe-form__section">
        <h3 class="recipe-form__section-title">{{ $t('forms.recipe.sections.basicInfo') }}</h3>

        <div class="recipe-form__field">
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

        <div class="recipe-form__row">
          <div class="recipe-form__field">
            <label for="language" class="recipe-form__label">
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
        </div>
      </section>

      <!-- Servings -->
      <section class="recipe-form__section">
        <h3 class="recipe-form__section-title">{{ $t('forms.recipe.sections.servings') }}</h3>

        <div class="recipe-form__row">
          <div class="recipe-form__field">
            <label for="servings_original" class="recipe-form__label required">
              {{ $t('forms.recipe.servings.original') }}
            </label>
            <InputNumber
              id="servings_original"
              v-model="formData.servings!.original"
              :min="1"
              :max="100"
              class="recipe-form__input"
              required
            />
          </div>

          <div class="recipe-form__field">
            <label for="servings_min" class="recipe-form__label">
              {{ $t('forms.recipe.servings.min') }}
            </label>
            <InputNumber
              id="servings_min"
              v-model="formData.servings!.min"
              :min="1"
              :max="100"
              class="recipe-form__input"
            />
          </div>

          <div class="recipe-form__field">
            <label for="servings_max" class="recipe-form__label">
              {{ $t('forms.recipe.servings.max') }}
            </label>
            <InputNumber
              id="servings_max"
              v-model="formData.servings!.max"
              :min="1"
              :max="100"
              class="recipe-form__input"
            />
          </div>
        </div>

        <small class="recipe-form__help-text">{{ $t('forms.recipe.servings.hint') }}</small>
      </section>

      <!-- Timing -->
      <section class="recipe-form__section">
        <h3 class="recipe-form__section-title">{{ $t('forms.recipe.sections.timing') }}</h3>

        <div class="recipe-form__row">
          <div class="recipe-form__field">
            <label for="prep_time" class="recipe-form__label">
              {{ $t('forms.recipe.prepTime') }}
            </label>
            <InputNumber
              id="prep_time"
              v-model="formData.timing!.prep_minutes"
              :min="0"
              :max="1440"
              suffix=" min"
              :placeholder="'e.g. 15'"
              class="recipe-form__input"
            />
            <small class="recipe-form__help-text">{{ $t('forms.recipe.prepTimeHint') }}</small>
          </div>

          <div class="recipe-form__field">
            <label for="cook_time" class="recipe-form__label">
              {{ $t('forms.recipe.cookTime') }}
            </label>
            <InputNumber
              id="cook_time"
              v-model="formData.timing!.cook_minutes"
              :min="0"
              :max="1440"
              suffix=" min"
              :placeholder="'e.g. 30'"
              class="recipe-form__input"
            />
            <small class="recipe-form__help-text">{{ $t('forms.recipe.cookTimeHint') }}</small>
          </div>

          <div class="recipe-form__field">
            <label for="total_time" class="recipe-form__label">
              {{ $t('forms.recipe.totalTime') }}
            </label>
            <InputNumber
              id="total_time"
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

      <!-- Precision -->
      <section class="recipe-form__section">
        <h3 class="recipe-form__section-title">{{ $t('forms.recipe.sections.precision') }}</h3>

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

        <div v-if="formData.requires_precision" class="recipe-form__field">
          <label for="precision_reason" class="recipe-form__label">
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

      <!-- Tags & Classification -->
      <section class="recipe-form__section">
        <h3 class="recipe-form__section-title">{{ $t('forms.recipe.sections.classification') }}</h3>

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

      <!-- Aliases -->
      <section class="recipe-form__section">
        <h3 class="recipe-form__section-title">{{ $t('forms.recipe.sections.aliases') }}</h3>

        <div class="recipe-form__field">
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
      </section>

      <!-- Ingredient Groups -->
      <section
        v-for="(group, groupIndex) in formData.ingredient_groups"
        :key="groupIndex"
        class="recipe-form__section"
      >
        <div class="recipe-form__section-header">
          <h3 class="recipe-form__section-title">
            {{ $t('forms.recipe.sections.ingredients') }} {{ groupIndex + 1 }}
          </h3>
          <Button
            v-if="formData.ingredient_groups!.length > 1"
            type="button"
            icon="pi pi-trash"
            :label="$t('forms.recipe.removeGroup')"
            severity="danger"
            size="small"
            outlined
            @click="removeIngredientGroup(groupIndex)"
          />
        </div>

        <div class="recipe-form__field">
          <label :for="'group-name-' + groupIndex" class="recipe-form__label">
            {{ $t('forms.recipe.groupName') }}
          </label>
          <InputText
            :id="'group-name-' + groupIndex"
            v-model="group.name"
            :placeholder="$t('forms.recipe.groupNamePlaceholder')"
            class="recipe-form__input"
          />
        </div>

        <div
          v-for="(item, itemIndex) in group.items"
          :key="itemIndex"
          class="recipe-form__ingredient"
        >
          <div class="recipe-form__ingredient-row recipe-form__ingredient-row--main">
            <div class="recipe-form__field">
              <label :for="'ingredient-name-' + groupIndex + '-' + itemIndex" class="recipe-form__label">
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

            <Button
              type="button"
              icon="pi pi-trash"
              severity="danger"
              size="small"
              text
              @click="removeIngredient(groupIndex, itemIndex)"
            />
          </div>

          <div class="recipe-form__ingredient-row recipe-form__ingredient-row--secondary">
            <div class="recipe-form__field">
              <label :for="'ingredient-notes-' + groupIndex + '-' + itemIndex" class="recipe-form__label">
                {{ $t('forms.recipe.ingredientNotes') }}
              </label>
              <InputText
                :id="'ingredient-notes-' + groupIndex + '-' + itemIndex"
                v-model="item.notes"
                :placeholder="$t('forms.recipe.ingredientNotesPlaceholder')"
                class="recipe-form__input"
              />
            </div>

            <div class="recipe-form__checkbox-field">
              <Checkbox
                :id="'ingredient-optional-' + groupIndex + '-' + itemIndex"
                v-model="item.optional"
                :binary="true"
              />
              <label :for="'ingredient-optional-' + groupIndex + '-' + itemIndex" class="recipe-form__label-inline">
                {{ $t('forms.recipe.ingredientOptional') }}
              </label>
            </div>
          </div>
        </div>

        <Button
          type="button"
          :label="$t('forms.recipe.addIngredient')"
          icon="pi pi-plus"
          severity="secondary"
          outlined
          @click="addIngredient(groupIndex)"
        />
      </section>

      <div class="recipe-form__add-group-wrapper">
        <Button
          type="button"
          :label="$t('forms.recipe.addGroup')"
          icon="pi pi-plus"
          severity="secondary"
          @click="addIngredientGroup"
        />
      </div>

      <!-- Steps -->
      <section class="recipe-form__section">
        <div class="recipe-form__section-header">
          <h3 class="recipe-form__section-title">{{ $t('forms.recipe.sections.steps') }}</h3>
          <Button
            type="button"
            :label="$t('forms.recipe.addStep')"
            icon="pi pi-plus"
            severity="secondary"
            size="small"
            @click="addStep"
          />
        </div>

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
            v-model="step.instructions[formData.language!]"
            :placeholder="$t('forms.recipe.stepInstruction')"
            rows="3"
            class="recipe-form__step-instruction"
            required
          />
        </div>
      </section>

      <!-- Equipment -->
      <section class="recipe-form__section">
        <h3 class="recipe-form__section-title">{{ $t('forms.recipe.sections.equipment') }}</h3>

        <div class="recipe-form__field">
          <label for="equipment" class="recipe-form__label">
            {{ $t('forms.recipe.equipment') }}
          </label>
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

      <!-- Admin Notes -->
      <section class="recipe-form__section">
        <h3 class="recipe-form__section-title">{{ $t('forms.recipe.sections.adminNotes') }}</h3>

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

      <!-- Validation Errors -->
      <div v-if="!isValid && validationErrors.length > 0" class="recipe-form__validation-errors">
        <div class="recipe-form__validation-header">
          <i class="pi pi-exclamation-triangle"></i>
          <span>Please fix the following errors before saving:</span>
        </div>
        <ul class="recipe-form__validation-list">
          <li v-for="(error, index) in validationErrors" :key="index">
            {{ error }}
          </li>
        </ul>
      </div>

      <!-- Form Actions -->
      <div class="recipe-form__actions">
        <Button
          type="button"
          :label="$t('common.buttons.cancel')"
          severity="secondary"
          outlined
          @click="handleCancel"
        />
        <Button
          type="submit"
          :label="$t('common.buttons.save')"
          :loading="loading"
          :disabled="!isValid"
          :title="!isValid ? validationErrors[0] : ''"
        />
      </div>
    </form>
  </div>
</template>

<style scoped>
.recipe-form {
  background: var(--color-surface);
  border-radius: var(--border-radius-lg);
  padding: var(--spacing-xl);
}

.recipe-form__section {
  margin-bottom: var(--spacing-2xl);
  padding-bottom: var(--spacing-xl);
  border-bottom: var(--border-width) solid var(--color-border);
}

.recipe-form__section:last-of-type {
  border-bottom: none;
}

.recipe-form__section-title {
  font-size: var(--font-size-xl);
  font-weight: var(--font-weight-semibold);
  color: var(--color-text);
  margin-bottom: var(--spacing-lg);
}

.recipe-form__section-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: var(--spacing-lg);
}

.recipe-form__field {
  margin-bottom: var(--spacing-lg);
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
  margin-bottom: var(--spacing-lg);
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

.recipe-form__tags {
  display: flex;
  flex-wrap: wrap;
  gap: var(--spacing-sm);
  margin-top: var(--spacing-sm);
}

.recipe-form__tag {
  display: inline-flex;
  align-items: center;
  gap: var(--spacing-xs);
  padding: var(--spacing-xs) var(--spacing-sm);
  background: var(--color-primary-light);
  color: var(--color-primary);
  border-radius: var(--border-radius-sm);
  font-size: var(--font-size-sm);
}

.recipe-form__tag button {
  background: none;
  border: none;
  color: var(--color-primary);
  font-size: var(--font-size-lg);
  cursor: pointer;
  padding: 0;
  line-height: 1;
}

.recipe-form__ingredient {
  padding: 0;
  background: var(--color-background);
  border-radius: var(--border-radius-md);
  margin-bottom: var(--spacing-md);
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
  grid-template-columns: 2fr 1fr 1fr auto;
  align-items: flex-end;
}

.recipe-form__ingredient-row--secondary {
  grid-template-columns: 1fr auto;
  margin-bottom: 0;
  align-items: center;
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

/* Validation Errors */
.recipe-form__validation-errors {
  margin-top: var(--spacing-lg);
  padding: var(--spacing-lg);
  background: var(--color-error-light, #fee);
  border: 1px solid var(--color-error, #dc3545);
  border-radius: var(--border-radius-md);
}

.recipe-form__validation-header {
  display: flex;
  align-items: center;
  gap: var(--spacing-sm);
  font-weight: var(--font-weight-semibold);
  color: var(--color-error, #dc3545);
  margin-bottom: var(--spacing-md);
}

.recipe-form__validation-header i {
  font-size: var(--font-size-lg);
}

.recipe-form__validation-list {
  margin: 0;
  padding-left: var(--spacing-xl);
  color: var(--color-text);
}

.recipe-form__validation-list li {
  margin-bottom: var(--spacing-xs);
}

/* Actions */
.recipe-form__actions {
  display: flex;
  justify-content: flex-end;
  gap: var(--spacing-md);
  padding-top: var(--spacing-xl);
}

/* Mobile responsive */
@media (max-width: 768px) {
  .recipe-form__row {
    grid-template-columns: 1fr;
  }

  .recipe-form__ingredient-row {
    grid-template-columns: 1fr;
  }
}
</style>
