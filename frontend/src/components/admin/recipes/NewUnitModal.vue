<script setup lang="ts">
import { ref, computed, watch } from 'vue'
import { useUnitStore } from '@/stores/unitStore'
import type { UnitCategory } from '@/services/types'
import Dialog from 'primevue/dialog'
import InputText from 'primevue/inputtext'
import Select from 'primevue/select'
import Button from 'primevue/button'

interface Props {
  visible: boolean
  unitName: string
}

const props = defineProps<Props>()

const emit = defineEmits<{
  'update:visible': [value: boolean]
  'unit-created': [canonicalName: string]
  cancel: []
}>()

const unitStore = useUnitStore()

const canonicalName = ref('')
const selectedCategory = ref<UnitCategory>('unit_other')
const creating = ref(false)
const error = ref<string | null>(null)

const categoryOptions = [
  { label: 'Volume (ml, cup, tbsp)', value: 'unit_volume' },
  { label: 'Weight (g, kg, oz)', value: 'unit_weight' },
  { label: 'Quantity (piece, slice)', value: 'unit_quantity' },
  { label: 'Length (cm, inch)', value: 'unit_length' },
  { label: 'Other', value: 'unit_other' }
]

const isVisible = computed({
  get: () => props.visible,
  set: (value) => emit('update:visible', value)
})

watch(() => props.unitName, (newName) => {
  canonicalName.value = newName.toLowerCase().trim()
})

async function handleCreate() {
  if (!canonicalName.value.trim()) {
    error.value = 'Unit name is required'
    return
  }

  creating.value = true
  error.value = null

  const newUnit = await unitStore.createUnit(
    canonicalName.value.trim(),
    selectedCategory.value,
    true
  )

  creating.value = false

  if (newUnit) {
    emit('unit-created', newUnit.canonical_name)
    isVisible.value = false
  } else {
    error.value = unitStore.error || 'Failed to create unit'
  }
}

function handleCancel() {
  emit('cancel')
  isVisible.value = false
}
</script>

<template>
  <Dialog
    v-model:visible="isVisible"
    header="Add New Unit"
    :style="{ width: '400px' }"
    modal
    :closable="!creating"
  >
    <div class="new-unit-modal">
      <p class="new-unit-modal__intro">
        The unit "<strong>{{ unitName }}</strong>" doesn't exist yet.
        Add it to the database and translations will be generated automatically.
      </p>

      <div v-if="error" class="new-unit-modal__error">
        {{ error }}
      </div>

      <div class="new-unit-modal__field">
        <label for="unit-canonical-name" class="new-unit-modal__label">
          Canonical Name
        </label>
        <InputText
          id="unit-canonical-name"
          v-model="canonicalName"
          placeholder="e.g., tbsp, cup, clove"
          class="new-unit-modal__input"
          :disabled="creating"
        />
        <small class="new-unit-modal__help">
          Use lowercase. This is the standard identifier for the unit.
        </small>
      </div>

      <div class="new-unit-modal__field">
        <label for="unit-category" class="new-unit-modal__label">
          Category
        </label>
        <Select
          id="unit-category"
          v-model="selectedCategory"
          :options="categoryOptions"
          optionLabel="label"
          optionValue="value"
          placeholder="Select category"
          class="new-unit-modal__input"
          :disabled="creating"
        />
      </div>
    </div>

    <template #footer>
      <Button
        label="Cancel"
        severity="secondary"
        @click="handleCancel"
        :disabled="creating"
      />
      <Button
        label="Create & Translate"
        icon="pi pi-language"
        @click="handleCreate"
        :loading="creating"
      />
    </template>
  </Dialog>
</template>

<style scoped>
.new-unit-modal {
  display: flex;
  flex-direction: column;
  gap: var(--spacing-lg);
}

.new-unit-modal__intro {
  margin: 0;
  color: var(--color-text-muted);
  line-height: 1.5;
}

.new-unit-modal__error {
  background-color: #fee;
  border: 1px solid #fcc;
  border-radius: var(--border-radius-md);
  padding: var(--spacing-md);
  color: #d32f2f;
  font-size: var(--font-size-sm);
}

.new-unit-modal__field {
  display: flex;
  flex-direction: column;
  gap: var(--spacing-xs);
}

.new-unit-modal__label {
  font-weight: var(--font-weight-medium);
  font-size: var(--font-size-sm);
}

.new-unit-modal__input {
  width: 100%;
}

.new-unit-modal__help {
  font-size: var(--font-size-xs);
  color: var(--color-text-muted);
}
</style>
