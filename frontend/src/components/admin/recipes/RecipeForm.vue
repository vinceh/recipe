<script setup lang="ts">
import { ref, computed, watch, onMounted, nextTick } from 'vue'
import { useI18n } from 'vue-i18n'
import { useDataReferenceStore } from '@/stores/dataReferenceStore'
import { useUiStore } from '@/stores/uiStore'
import { useUnitStore } from '@/stores/unitStore'
import type { Recipe, RecipeIngredientGroup, RecipeIngredientItem, RecipeStep, RecipeStepImage, Unit, InstructionItem } from '@/services/types'
import InputText from 'primevue/inputtext'
import InputNumber from 'primevue/inputnumber'
import Textarea from 'primevue/textarea'
import Select from 'primevue/select'
import MultiSelect from 'primevue/multiselect'
import Button from 'primevue/button'
import Checkbox from 'primevue/checkbox'
import AutoComplete from 'primevue/autocomplete'
import ReorderableItemActions from '@/components/shared/ReorderableItemActions.vue'
import NewUnitModal from './NewUnitModal.vue'

// Props & Emits
interface Props {
  modelValue?: Partial<Recipe> | null
  loading?: boolean
  hideImport?: boolean
}

const props = withDefaults(defineProps<Props>(), {
  modelValue: null,
  loading: false,
  hideImport: false
})

const emit = defineEmits<{
  'update:modelValue': [value: Partial<Recipe>]
  save: []
  cancel: []
  'import-text': []
  'import-url': []
}>()

// Local type for step images in form (extends API type with file handling)
interface LocalStepImage {
  id?: number
  position: number
  caption: string
  ai_generated: boolean
  url: string | null
  file?: File
  previewUrl?: string
}

// Composables
const { t, locale } = useI18n()
const dataStore = useDataReferenceStore()
const uiStore = useUiStore()
const unitStore = useUnitStore()

// Unit autocomplete state
interface UnitSuggestion extends Unit {
  name: string
}
const unitSuggestions = ref<UnitSuggestion[]>([])
const showNewUnitModal = ref(false)
const newUnitData = ref<{ name: string; groupIndex: number; itemIndex: number } | null>(null)

function searchUnits(event: { query: string }) {
  const units = unitStore.searchUnits(event.query)
  unitSuggestions.value = units.map(u => ({
    ...u,
    name: unitStore.getTranslatedName(u) || u.canonical_name
  }))
}

function onUnitSelect(event: { value: Unit | string }, groupIndex: number, itemIndex: number) {
  const groups = formData.value.ingredient_groups
  if (!groups || !groups[groupIndex]) return
  const item = groups[groupIndex].items[itemIndex]
  if (!item) return

  if (typeof event.value === 'object' && event.value.canonical_name) {
    item.unit = event.value.canonical_name
  } else if (typeof event.value === 'string') {
    item.unit = event.value
  }
}

function handleUnitBlur(groupIndex: number, itemIndex: number) {
  const groups = formData.value.ingredient_groups
  if (!groups || !groups[groupIndex]) return
  const item = groups[groupIndex].items[itemIndex]
  if (!item || !item.unit) return

  const existingUnit = unitStore.findByName(item.unit)
  if (!existingUnit && item.unit.trim()) {
    newUnitData.value = { name: item.unit.trim(), groupIndex, itemIndex }
    showNewUnitModal.value = true
  }
}

function handleUnitCreated(canonicalName: string) {
  if (newUnitData.value) {
    const { groupIndex, itemIndex } = newUnitData.value
    const groups = formData.value.ingredient_groups
    if (groups && groups[groupIndex]?.items[itemIndex]) {
      groups[groupIndex].items[itemIndex].unit = canonicalName
    }
  }
  newUnitData.value = null
}

function handleUnitModalCancel() {
  if (newUnitData.value) {
    const { groupIndex, itemIndex } = newUnitData.value
    const groups = formData.value.ingredient_groups
    if (groups && groups[groupIndex]?.items[itemIndex]) {
      groups[groupIndex].items[itemIndex].unit = ''
    }
  }
  newUnitData.value = null
}

// Form state - matches backend Recipe model exactly
const formData = ref<Partial<Recipe>>({
  name: '',
  language: 'en',
  source_url: '',
  requires_precision: false,
  precision_reason: undefined,
  difficulty_level: undefined,
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
  cuisines: [],
  tags: [],
  ingredient_groups: [
    {
      name: '',
      items: []
    }
  ],
  steps: [],
  instruction_items: [],
  equipment: [],
  admin_notes: ''
})

// Separate ref for step images (handled differently due to file uploads)
const stepImages = ref<LocalStepImage[]>([])

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

function moveIngredientUp(groupIndex: number, ingredientIndex: number) {
  const groups = formData.value.ingredient_groups
  if (groups && groups[groupIndex] && ingredientIndex > 0) {
    const items = groups[groupIndex].items
    const temp = items[ingredientIndex]
    items[ingredientIndex] = items[ingredientIndex - 1]
    items[ingredientIndex - 1] = temp
  }
}

function moveIngredientDown(groupIndex: number, ingredientIndex: number) {
  const groups = formData.value.ingredient_groups
  if (groups && groups[groupIndex]) {
    const items = groups[groupIndex].items
    if (ingredientIndex < items.length - 1) {
      const temp = items[ingredientIndex]
      items[ingredientIndex] = items[ingredientIndex + 1]
      items[ingredientIndex + 1] = temp
    }
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

// Step image helpers
let nextStepImageId = 1

function addStepImageAfter(stepIndex: number) {
  const position = stepIndex + 1.5
  stepImages.value.push({
    position,
    caption: '',
    ai_generated: false,
    url: null,
    file: undefined,
    previewUrl: undefined
  })
  stepImages.value.sort((a, b) => a.position - b.position)
}

function removeStepImage(index: number) {
  const img = stepImages.value[index]
  if (img?.previewUrl) {
    URL.revokeObjectURL(img.previewUrl)
  }
  stepImages.value.splice(index, 1)
}

function handleStepImageSelect(event: Event, imageIndex: number) {
  const input = event.target as HTMLInputElement
  const file = input.files?.[0]

  if (file) {
    const validTypes = ['image/png', 'image/jpeg', 'image/gif', 'image/webp']
    const maxSize = 10 * 1024 * 1024

    if (!validTypes.includes(file.type)) {
      alert('Please select a valid image file (PNG, JPG, GIF, or WebP)')
      return
    }

    if (file.size > maxSize) {
      alert('Image size must be less than 10MB')
      return
    }

    const img = stepImages.value[imageIndex]
    if (img) {
      if (img.previewUrl) {
        URL.revokeObjectURL(img.previewUrl)
      }
      img.file = file
      img.previewUrl = URL.createObjectURL(file)
    }
  }
}

function getStepImagesAfterStep(stepIndex: number): { image: LocalStepImage; index: number }[] {
  const stepOrder = stepIndex + 1
  return stepImages.value
    .map((img, idx) => ({ image: img, index: idx }))
    .filter(({ image }) => image.position > stepOrder && image.position < stepOrder + 1)
}

function moveStepImageUp(imageIndex: number) {
  const img = stepImages.value[imageIndex]
  if (!img) return

  const currentPos = img.position
  const stepBefore = Math.floor(currentPos)

  if (stepBefore > 1) {
    img.position = stepBefore - 0.5
  } else if (stepBefore === 1) {
    img.position = 0.5
  }
  stepImages.value.sort((a, b) => a.position - b.position)
}

function moveStepImageDown(imageIndex: number) {
  const img = stepImages.value[imageIndex]
  if (!img) return

  const currentPos = img.position
  const stepBefore = Math.floor(currentPos)
  const totalSteps = formData.value.steps?.length || 0

  if (stepBefore < totalSteps) {
    img.position = stepBefore + 1.5
  }
  stepImages.value.sort((a, b) => a.position - b.position)
}

// Instruction item helpers
let nextInstructionItemId = 1

function getNextPosition(): number {
  const items = formData.value.instruction_items || []
  if (items.length === 0) return 1
  return Math.max(...items.map(i => i.position)) + 1
}

function addInstructionHeading() {
  if (!formData.value.instruction_items) formData.value.instruction_items = []
  formData.value.instruction_items.push({
    id: nextInstructionItemId++,
    item_type: 'heading',
    position: getNextPosition(),
    content: ''
  })
}

function addInstructionText() {
  if (!formData.value.instruction_items) formData.value.instruction_items = []
  formData.value.instruction_items.push({
    id: nextInstructionItemId++,
    item_type: 'text',
    position: getNextPosition(),
    content: ''
  })
}

function addInstructionImage() {
  if (!formData.value.instruction_items) formData.value.instruction_items = []
  formData.value.instruction_items.push({
    id: nextInstructionItemId++,
    item_type: 'image',
    position: getNextPosition(),
    content: ''
  })
}

function removeInstructionItem(index: number) {
  formData.value.instruction_items?.splice(index, 1)
  reorderInstructionItems()
}

function moveInstructionItemUp(index: number) {
  const items = formData.value.instruction_items
  if (!items || index <= 0) return
  const temp = items[index - 1]!
  items[index - 1] = items[index]!
  items[index] = temp
  reorderInstructionItems()
}

function moveInstructionItemDown(index: number) {
  const items = formData.value.instruction_items
  if (!items || index >= items.length - 1) return
  const temp = items[index]!
  items[index] = items[index + 1]!
  items[index + 1] = temp
  reorderInstructionItems()
}

function reorderInstructionItems() {
  formData.value.instruction_items?.forEach((item, index) => {
    item.position = index + 1
  })
}

// Instruction item image file handling
const instructionImageFiles = ref<Map<number, File>>(new Map())
const instructionImagePreviews = ref<Map<number, string>>(new Map())

function handleInstructionImageSelect(event: Event, itemId: number) {
  const input = event.target as HTMLInputElement
  const file = input.files?.[0]

  if (file) {
    const validTypes = ['image/png', 'image/jpeg', 'image/gif', 'image/webp']
    const maxSize = 10 * 1024 * 1024

    if (!validTypes.includes(file.type)) {
      alert('Please select a valid image file (PNG, JPG, GIF, or WebP)')
      return
    }

    if (file.size > maxSize) {
      alert('Image size must be less than 10MB')
      return
    }

    // Clear any existing preview
    const existingPreview = instructionImagePreviews.value.get(itemId)
    if (existingPreview) {
      URL.revokeObjectURL(existingPreview)
    }

    instructionImageFiles.value.set(itemId, file)
    instructionImagePreviews.value.set(itemId, URL.createObjectURL(file))

    // Update the item to mark it has a file
    const item = formData.value.instruction_items?.find(i => i.id === itemId)
    if (item) {
      item.image_file = file
    }
  }
}

function getInstructionImagePreview(item: InstructionItem): string | null {
  if (item.id && instructionImagePreviews.value.has(item.id)) {
    return instructionImagePreviews.value.get(item.id) || null
  }
  return item.image_url || null
}

// Image upload handling
const selectedImageFile = ref<File | null>(null)
const imagePreview = ref<string | null>(null)

function handleImageSelect(event: Event) {
  const input = event.target as HTMLInputElement
  const file = input.files?.[0]

  if (file) {
    const validTypes = ['image/png', 'image/jpeg', 'image/gif', 'image/webp']
    const maxSize = 10 * 1024 * 1024

    if (!validTypes.includes(file.type)) {
      alert('Please select a valid image file (PNG, JPG, GIF, or WebP)')
      return
    }

    if (file.size > maxSize) {
      alert('Image size must be less than 10MB')
      return
    }

    selectedImageFile.value = file
    const reader = new FileReader()
    reader.onload = (e) => {
      imagePreview.value = e.target?.result as string
    }
    reader.readAsDataURL(file)
  }
}

function removeImage() {
  selectedImageFile.value = null
  imagePreview.value = null
  const fileInput = document.getElementById('recipe-image') as HTMLInputElement
  if (fileInput) {
    fileInput.value = ''
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

// Tags (free-form)
const tagInput = ref('')
function addTag() {
  if (tagInput.value.trim() && formData.value.tags) {
    const tag = tagInput.value.trim().toLowerCase()
    if (!formData.value.tags.includes(tag)) {
      formData.value.tags.push(tag)
    }
    tagInput.value = ''
  }
}

function removeTag(index: number) {
  formData.value.tags?.splice(index, 1)
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

const precisionReasonOptions = computed(() => [
  { label: t('forms.recipe.precisionReasons.baking'), value: 'baking' },
  { label: t('forms.recipe.precisionReasons.confectionery'), value: 'confectionery' },
  { label: t('forms.recipe.precisionReasons.fermentation'), value: 'fermentation' },
  { label: t('forms.recipe.precisionReasons.molecular'), value: 'molecular' }
])

const difficultyLevelOptions = computed(() => [
  { label: t('forms.recipe.difficultyLevels.easy'), value: 'easy' },
  { label: t('forms.recipe.difficultyLevels.medium'), value: 'medium' },
  { label: t('forms.recipe.difficultyLevels.hard'), value: 'hard' }
])

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

  // Required: Difficulty level
  if (!formData.value.difficulty_level) {
    validationErrors.value.push('Difficulty level is required')
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

  // Required: At least one instruction item (text type)
  const textItems = formData.value.instruction_items?.filter(i => i.item_type === 'text') || []
  if (textItems.length === 0) {
    validationErrors.value.push('At least one step text is required')
  } else {
    // Each text instruction must have content
    textItems.forEach((item, i) => {
      if (!item.content || item.content.trim().length === 0) {
        validationErrors.value.push(`Step text ${i + 1} must have instructions`)
      }
    })
  }

  // Heading items must have content if present
  const headingItems = formData.value.instruction_items?.filter(i => i.item_type === 'heading') || []
  headingItems.forEach((item, i) => {
    if (!item.content || item.content.trim().length === 0) {
      validationErrors.value.push(`Section heading ${i + 1} must have text`)
    }
  })

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

  // Required: At least one cuisine
  if (!formData.value.cuisines || formData.value.cuisines.length === 0) {
    validationErrors.value.push('At least one cuisine is required')
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
    if (!formData.value.instruction_items) formData.value.instruction_items = []
    if (!formData.value.equipment) formData.value.equipment = []
    if (!formData.value.aliases) formData.value.aliases = []
    if (!formData.value.dietary_tags) formData.value.dietary_tags = []
    if (!formData.value.cuisines) formData.value.cuisines = []
    if (!formData.value.tags) formData.value.tags = []
    if (!formData.value.difficulty_level) formData.value.difficulty_level = undefined

    // Load existing step images from recipe
    if (newValue.step_images && newValue.step_images.length > 0) {
      stepImages.value = newValue.step_images.map(img => ({
        id: img.id,
        position: img.position,
        caption: img.caption || '',
        ai_generated: img.ai_generated,
        url: img.url,
        file: undefined,
        previewUrl: undefined
      }))
    } else {
      stepImages.value = []
    }

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

// Method to set precision_reason from external scripts (like formtest.js)
function setPrecisionReason(value: string) {
  if (formData.value) {
    formData.value.precision_reason = value as 'baking' | 'confectionery' | 'fermentation' | 'molecular'
  }
}

// Expose validation and setter methods for parent and external scripts
defineExpose({
  validateForm,
  isValid,
  setPrecisionReason,
  selectedImageFile,
  stepImages,
  instructionImageFiles
})

// Lifecycle
onMounted(async () => {
  // Fetch data references if not already loaded
  if (dataStore.dietaryTags.length === 0 ||
      dataStore.cuisines.length === 0) {
    await dataStore.fetchAll()
  }

  // Fetch units for autocomplete
  await unitStore.fetchUnits()

  // Initialize with at least one ingredient and one instruction text if empty
  if (formData.value.ingredient_groups && formData.value.ingredient_groups.length > 0) {
    const firstGroup = formData.value.ingredient_groups[0]
    if (firstGroup && firstGroup.items.length === 0) {
      addIngredient(0)
    }
  }
  if (!formData.value.instruction_items || formData.value.instruction_items.length === 0) {
    addInstructionText()
  }
})

// Watch for language changes and reload data references
watch(() => uiStore.language, async () => {
  dataStore.clearAll()
  await dataStore.fetchAll()
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
      <div v-if="!hideImport" class="recipe-form__import-buttons">
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

      <hr v-if="!hideImport" />

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

        <div class="recipe-form__field recipe-form__field--wide">
          <label for="description" class="recipe-form__label">
            {{ $t('common.labels.description') }}
          </label>
          <Textarea
            id="description"
            v-model="formData.description"
            :placeholder="$t('common.labels.description')"
            class="recipe-form__input"
            rows="3"
            autoResize
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

        <div class="recipe-form__field recipe-form__field--medium">
          <label for="difficulty_level" class="recipe-form__label required">
            {{ $t('forms.recipe.difficultyLevel') }}
          </label>
          <Select
            id="difficulty_level"
            v-model="formData.difficulty_level"
            :options="difficultyLevelOptions"
            optionLabel="label"
            optionValue="value"
            :placeholder="$t('forms.recipe.difficultyLevelPlaceholder')"
            class="recipe-form__input"
          />
        </div>

        <div class="recipe-form__field">
          <button
            type="button"
            class="recipe-form__checkbox-button"
            @click="formData.requires_precision = !formData.requires_precision"
          >
            <Checkbox
              id="requires_precision"
              v-model="formData.requires_precision"
              :binary="true"
            />
            <span class="recipe-form__label-inline">
              {{ $t('forms.recipe.requiresPrecision') }}
            </span>
          </button>
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

      <!-- Recipe Image -->
      <section class="recipe-form__section">
        <h2 class="recipe-form__section-title">{{ $t('forms.recipe.sections.image') }}</h2>

        <div class="recipe-form__field">
          <label for="recipe-image" class="recipe-form__label">
            {{ $t('forms.recipe.image') }}
          </label>
          <div class="recipe-form__image-upload">
            <input
              id="recipe-image"
              type="file"
              accept="image/png,image/jpeg,image/gif,image/webp"
              class="recipe-form__file-input"
              @change="handleImageSelect"
            />
            <label for="recipe-image" class="recipe-form__file-label">
              <i class="pi pi-cloud-upload"></i>
              <span>{{ $t('forms.recipe.imageUploadPlaceholder') }}</span>
            </label>
          </div>
          <small class="recipe-form__help-text">{{ $t('forms.recipe.imageUploadHint') }}</small>
        </div>

        <div v-if="imagePreview || formData.image_url" class="recipe-form__image-preview">
          <img :src="imagePreview || formData.image_url" :alt="formData.name || 'Recipe image'" />
          <Button
            type="button"
            icon="pi pi-trash"
            severity="danger"
            size="small"
            :label="$t('common.buttons.remove')"
            @click="removeImage"
            class="recipe-form__remove-image-btn"
          />
        </div>
      </section>

      <!-- Tags & Classification -->
      <section class="recipe-form__section">
        <h2 class="recipe-form__section-title">{{ $t('forms.recipe.sections.classification') }}</h2>

        <div class="recipe-form__field">
          <label for="cuisines" class="recipe-form__label required">
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
          <label for="tags" class="recipe-form__label">
            {{ $t('forms.recipe.tags') }}
          </label>
          <div class="recipe-form__input-with-button">
            <InputText
              id="tags"
              v-model="tagInput"
              :placeholder="$t('forms.recipe.tagsPlaceholder')"
              class="recipe-form__input"
              @keydown.enter.prevent="addTag"
            />
            <Button
              type="button"
              :label="$t('common.buttons.add')"
              severity="success"
              @click="addTag"
            />
          </div>
          <small class="recipe-form__help-text">{{ $t('forms.recipe.tagsHint') }}</small>
        </div>

        <div v-if="formData.tags && formData.tags.length > 0" class="recipe-form__tags">
          <span
            v-for="(tag, index) in formData.tags"
            :key="index"
            class="recipe-form__tag"
          >
            {{ tag }}
            <button type="button" @click="removeTag(index)">×</button>
          </span>
        </div>
      </section>

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
            <div class="recipe-form__ingredient-header">
              <span class="recipe-form__ingredient-label">
                <i class="pi pi-shopping-cart"></i>
                Ingredient {{ itemIndex + 1 }}
              </span>
              <ReorderableItemActions
                :can-move-up="itemIndex > 0"
                :can-move-down="itemIndex < (group.items?.length || 0) - 1"
                @move-up="moveIngredientUp(groupIndex, itemIndex)"
                @move-down="moveIngredientDown(groupIndex, itemIndex)"
                @delete="removeIngredient(groupIndex, itemIndex)"
              />
            </div>

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
                <AutoComplete
                  :id="'ingredient-unit-' + groupIndex + '-' + itemIndex"
                  v-model="item.unit"
                  :suggestions="unitSuggestions"
                  optionLabel="name"
                  :placeholder="$t('forms.recipe.ingredientUnitPlaceholder')"
                  class="recipe-form__input recipe-form__unit-autocomplete"
                  dropdown
                  forceSelection
                  @complete="searchUnits"
                  @item-select="(e) => onUnitSelect(e, groupIndex, itemIndex)"
                  @blur="() => handleUnitBlur(groupIndex, itemIndex)"
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

      <!-- Instructions -->
      <section class="recipe-form__section">
        <h2 class="recipe-form__section-title">{{ $t('forms.recipe.sections.steps') }}</h2>

        <div class="recipe-form__instruction-items">
          <div
            v-for="(item, index) in formData.instruction_items"
            :key="item.id || index"
            class="recipe-form__instruction-item"
            :class="`recipe-form__instruction-item--${item.item_type}`"
          >
            <!-- Heading Item -->
            <template v-if="item.item_type === 'heading'">
              <div class="recipe-form__instruction-item-header">
                <span class="recipe-form__instruction-item-label">
                  <i class="pi pi-bookmark"></i>
                  Section Heading
                </span>
                <ReorderableItemActions
                  :can-move-up="index > 0"
                  :can-move-down="index < (formData.instruction_items?.length ?? 0) - 1"
                  :can-delete="true"
                  @move-up="moveInstructionItemUp(index)"
                  @move-down="moveInstructionItemDown(index)"
                  @delete="removeInstructionItem(index)"
                />
              </div>
              <InputText
                v-model="item.content"
                placeholder="e.g., Make the Sauce, Prepare the Dough"
                class="recipe-form__input recipe-form__heading-input"
              />
            </template>

            <!-- Text Item -->
            <template v-else-if="item.item_type === 'text'">
              <div class="recipe-form__instruction-item-header">
                <span class="recipe-form__instruction-item-label">
                  <i class="pi pi-align-left"></i>
                  Step Text
                </span>
                <ReorderableItemActions
                  :can-move-up="index > 0"
                  :can-move-down="index < (formData.instruction_items?.length ?? 0) - 1"
                  :can-delete="(formData.instruction_items?.filter(i => i.item_type === 'text')?.length ?? 0) > 1"
                  @move-up="moveInstructionItemUp(index)"
                  @move-down="moveInstructionItemDown(index)"
                  @delete="removeInstructionItem(index)"
                />
              </div>
              <Textarea
                v-model="item.content"
                :placeholder="$t('forms.recipe.stepInstruction')"
                rows="3"
                class="recipe-form__input"
              />
            </template>

            <!-- Image Item -->
            <template v-else-if="item.item_type === 'image'">
              <div class="recipe-form__instruction-item-header">
                <span class="recipe-form__instruction-item-label">
                  <i class="pi pi-image"></i>
                  Image
                </span>
                <ReorderableItemActions
                  :can-move-up="index > 0"
                  :can-move-down="index < (formData.instruction_items?.length ?? 0) - 1"
                  :can-delete="true"
                  @move-up="moveInstructionItemUp(index)"
                  @move-down="moveInstructionItemDown(index)"
                  @delete="removeInstructionItem(index)"
                />
              </div>

              <div v-if="getInstructionImagePreview(item)" class="recipe-form__instruction-image-preview">
                <img :src="getInstructionImagePreview(item)!" alt="Instruction image" />
              </div>

              <div v-else class="recipe-form__instruction-image-upload">
                <input
                  :id="`instruction-image-${item.id}`"
                  type="file"
                  accept="image/png,image/jpeg,image/gif,image/webp"
                  class="recipe-form__file-input"
                  @change="handleInstructionImageSelect($event, item.id!)"
                />
                <label :for="`instruction-image-${item.id}`" class="recipe-form__file-label recipe-form__file-label--small">
                  <i class="pi pi-cloud-upload"></i>
                  <span>Upload image</span>
                </label>
              </div>
            </template>
          </div>
        </div>

        <div class="recipe-form__add-instruction-buttons">
          <Button
            type="button"
            label="Add Section Heading"
            icon="pi pi-bookmark"
            severity="success"
            @click="addInstructionHeading"
          />
          <Button
            type="button"
            label="Add Step Text"
            icon="pi pi-align-left"
            severity="success"
            @click="addInstructionText"
          />
          <Button
            type="button"
            label="Add Image"
            icon="pi pi-image"
            severity="success"
            @click="addInstructionImage"
          />
        </div>
      </section>

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

    <!-- New Unit Modal -->
    <NewUnitModal
      v-model:visible="showNewUnitModal"
      :unit-name="newUnitData?.name || ''"
      @unit-created="handleUnitCreated"
      @cancel="handleUnitModalCancel"
    />
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
  padding: var(--spacing-md);
  margin-bottom: var(--spacing-lg);
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

.recipe-form__section {
  margin-bottom: 30px;
}

.recipe-form__field {
  margin-bottom: 15px;
}

.recipe-form__field--medium {
  max-width: 350px;
}

.recipe-form__field--one-third {
  max-width: calc(33.333% - var(--spacing-md) / 3);
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
  padding: var(--spacing-sm);
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

.recipe-form__ingredient-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: var(--spacing-sm);
}

.recipe-form__ingredient-label {
  display: flex;
  align-items: center;
  gap: var(--spacing-xs);
  font-size: var(--font-size-sm);
  font-weight: var(--font-weight-medium);
  color: var(--color-text-secondary);
}

.recipe-form__ingredient-row--main {
  grid-template-columns: 2fr 1fr 1fr;
}

.recipe-form__ingredient-row--notes {
  grid-template-columns: 1fr auto;
  margin-bottom: 0;
  align-items: end;
}

.recipe-form__checkbox-label {
  display: flex;
  align-items: center;
  gap: var(--spacing-sm);
  cursor: pointer;
  user-select: none;
}

.recipe-form__checkbox-button {
  display: flex;
  align-items: center;
  gap: var(--spacing-sm);
  padding: var(--spacing-md) var(--spacing-lg);
  background: white;
  border: 1px solid var(--color-border);
  border-radius: var(--border-radius-md);
  cursor: pointer;
  user-select: none;
  font-size: var(--font-size-md);
  transition: all 0.2s ease;
}

.recipe-form__checkbox-button:hover {
  background: var(--color-gray-50);
  border-color: var(--color-primary-light);
}

.recipe-form__checkbox-button:active {
  background: var(--color-gray-100);
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

.recipe-form__step-instruction {
  width: 100%;
}

.recipe-form__remove-group-btn :deep(.p-button-label) {
  color: white;
}

/* Ingredient grid responsive at 2200px */
@media (max-width: 2200px) {
  .recipe-form__ingredients-grid {
    grid-template-columns: 1fr;
  }
}

/* Image upload styling */
.recipe-form__image-upload {
  position: relative;
}

.recipe-form__file-input {
  display: none;
}

.recipe-form__file-label {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: var(--spacing-sm);
  padding: var(--spacing-2xl);
  border: 2px dashed var(--color-border);
  border-radius: var(--border-radius-md);
  background: var(--color-gray-50);
  cursor: pointer;
  transition: all 0.2s ease;
  user-select: none;
  color: var(--color-text-muted);
  font-size: var(--font-size-sm);
}

.recipe-form__file-label:hover {
  border-color: var(--color-primary);
  background: var(--color-primary-light);
  color: var(--color-primary);
}

.recipe-form__file-label i {
  font-size: 32px;
}

.recipe-form__file-label--small {
  padding: var(--spacing-lg);
}

.recipe-form__file-label--small i {
  font-size: 24px;
}

.recipe-form__image-preview {
  margin-top: var(--spacing-lg);
  position: relative;
  display: inline-block;
  max-width: 300px;
  border-radius: var(--border-radius-md);
  overflow: hidden;
}

.recipe-form__image-preview img {
  width: 100%;
  height: auto;
  display: block;
  border-radius: var(--border-radius-md);
}

.recipe-form__remove-image-btn {
  position: absolute;
  top: var(--spacing-sm);
  right: var(--spacing-sm);
}

/* Step container */
.recipe-form__step-container {
  margin-bottom: var(--spacing-lg);
}

/* Step image styles */
.recipe-form__step-image {
  background: var(--color-gray-50);
  border: 1px solid var(--color-border);
  border-radius: var(--border-radius-md);
  padding: var(--spacing-lg);
  margin: var(--spacing-md) 0;
  margin-left: var(--spacing-xl);
}

.recipe-form__step-image-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: var(--spacing-md);
}

.recipe-form__step-image-label {
  display: flex;
  align-items: center;
  gap: var(--spacing-sm);
  font-size: var(--font-size-sm);
  font-weight: var(--font-weight-medium);
  color: var(--color-text-muted);
}

.recipe-form__step-image-preview {
  position: relative;
  margin-bottom: var(--spacing-md);
  border-radius: var(--border-radius-md);
  overflow: hidden;
}

.recipe-form__step-image-preview img {
  width: 100%;
  max-width: 400px;
  height: auto;
  display: block;
  border-radius: var(--border-radius-md);
}

.recipe-form__ai-badge {
  position: absolute;
  bottom: var(--spacing-sm);
  left: var(--spacing-sm);
  background: rgba(0, 0, 0, 0.7);
  color: white;
  padding: var(--spacing-xs) var(--spacing-sm);
  border-radius: var(--border-radius-sm);
  font-size: var(--font-size-xs);
}

.recipe-form__step-image-upload {
  margin-bottom: var(--spacing-md);
}

.recipe-form__step-image-caption {
  margin-bottom: 0;
}

.recipe-form__add-image-row {
  margin: var(--spacing-sm) 0;
  margin-left: var(--spacing-xl);
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

  .recipe-form__image-preview {
    max-width: 100%;
  }

  .recipe-form__step-image {
    margin-left: 0;
  }

  .recipe-form__add-image-row {
    margin-left: 0;
  }
}

/* Unit autocomplete styles */
.recipe-form__unit-autocomplete :deep(.p-autocomplete-input) {
  width: 100%;
}

.recipe-form__unit-option {
  display: flex;
  justify-content: space-between;
  align-items: center;
  width: 100%;
  padding: var(--spacing-xs) 0;
}

.recipe-form__unit-name {
  font-weight: var(--font-weight-medium);
}

.recipe-form__unit-category {
  font-size: var(--font-size-xs);
  color: var(--color-text-muted);
  text-transform: capitalize;
  background: var(--color-gray-100);
  padding: 2px 8px;
  border-radius: var(--border-radius-sm);
}

/* Instruction items styles */
.recipe-form__instruction-items {
  display: flex;
  flex-direction: column;
  gap: var(--spacing-md);
  margin-bottom: var(--spacing-lg);
}

.recipe-form__instruction-item {
  background: white;
  border: 1px solid var(--color-border);
  border-radius: var(--border-radius-md);
  padding: var(--spacing-md);
}


.recipe-form__instruction-item-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: var(--spacing-sm);
}

.recipe-form__instruction-item-label {
  display: flex;
  align-items: center;
  gap: var(--spacing-sm);
  font-size: var(--font-size-sm);
  font-weight: var(--font-weight-medium);
  color: var(--color-text-muted);
}

.recipe-form__heading-input :deep(.p-inputtext) {
  font-weight: var(--font-weight-semibold);
  font-size: var(--font-size-lg);
}

.recipe-form__instruction-image-preview {
  margin-bottom: var(--spacing-md);
  border-radius: var(--border-radius-md);
  overflow: hidden;
}

.recipe-form__instruction-image-preview img {
  width: 100%;
  max-width: 400px;
  height: auto;
  display: block;
  border-radius: var(--border-radius-md);
}

.recipe-form__instruction-image-upload {
  margin-bottom: var(--spacing-md);
}

.recipe-form__add-instruction-buttons {
  display: flex;
  gap: var(--spacing-md);
  flex-wrap: wrap;
}
</style>
