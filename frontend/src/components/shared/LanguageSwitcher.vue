<script setup lang="ts">
import { computed } from 'vue'
import { useI18n } from 'vue-i18n'
import { useUiStore } from '@/stores'
import type { Language } from '@/stores/uiStore'

const { locale } = useI18n()
const uiStore = useUiStore()

interface LanguageOption {
  code: Language
  name: string
  nativeName: string
  flag: string
}

const languages: LanguageOption[] = [
  { code: 'en', name: 'English', nativeName: 'English', flag: '🇬🇧' },
  { code: 'ja', name: 'Japanese', nativeName: '日本語', flag: '🇯🇵' },
  { code: 'ko', name: 'Korean', nativeName: '한국어', flag: '🇰🇷' },
  { code: 'zh-tw', name: 'Traditional Chinese', nativeName: '繁體中文', flag: '🇹🇼' },
  { code: 'zh-cn', name: 'Simplified Chinese', nativeName: '简体中文', flag: '🇨🇳' },
  { code: 'es', name: 'Spanish', nativeName: 'Español', flag: '🇪🇸' },
  { code: 'fr', name: 'French', nativeName: 'Français', flag: '🇫🇷' }
]

const currentLanguage = computed(() => {
  return languages.find(lang => lang.code === locale.value) || languages[0]
})

function changeLanguage(languageCode: Language) {
  uiStore.setLanguage(languageCode)
}
</script>

<template>
  <div class="language-switcher">
    <select
      v-if="currentLanguage"
      :value="currentLanguage.code"
      @change="changeLanguage(($event.target as HTMLSelectElement).value as Language)"
      class="language-select"
      :aria-label="$t('common.labels.language')"
    >
      <option
        v-for="language in languages"
        :key="language.code"
        :value="language.code"
      >
        {{ language.flag }} {{ language.nativeName }}
      </option>
    </select>
  </div>
</template>

<style scoped>
.language-switcher {
  display: inline-block;
}

.language-select {
  padding: var(--spacing-xs) var(--spacing-sm);
  border: 1px solid var(--color-border);
  border-radius: var(--border-radius-sm);
  background-color: var(--color-background);
  color: var(--color-text);
  font-size: var(--font-size-base);
  font-family: var(--font-family-base) !important;
  font-weight: var(--font-weight-normal);
  cursor: pointer;
  transition: var(--transition-base);
}

.language-select:hover {
  border-color: var(--color-primary);
}

.language-select:focus {
  outline: none;
  border-color: var(--color-primary);
  box-shadow: 0 0 0 3px var(--color-primary-alpha);
}

.language-select option {
  padding: var(--spacing-xs);
  font-family: var(--font-family-base) !important;
  font-weight: var(--font-weight-normal);
}
</style>
