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
        {{ language.nativeName }}
      </option>
    </select>
  </div>
</template>

<style scoped>
.language-switcher {
  display: inline-block;
}

.language-select {
  padding: 5px 14px;
  padding-right: 30px;
  border: 1px solid var(--color-provisions-border);
  border-radius: 0;
  background-color: transparent;
  background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='12' height='12' viewBox='0 0 12 12'%3E%3Cpath fill='%23383630' d='M6 9L1 4h10z'/%3E%3C/svg%3E");
  background-repeat: no-repeat;
  background-position: right 10px center;
  color: var(--color-provisions-border);
  font-size: 20px;
  font-family: var(--font-family-heading) !important;
  font-weight: var(--font-weight-semibold);
  cursor: pointer;
  transition: var(--transition-base);
  appearance: none;
  -webkit-appearance: none;
  -moz-appearance: none;
}

.language-select:hover {
  border-color: var(--color-provisions-border);
}

.language-select:focus {
  outline: none;
  border-color: var(--color-provisions-border);
}

.language-select option {
  padding: var(--spacing-xs);
  font-family: var(--font-family-base) !important;
  font-weight: var(--font-weight-normal);
}
</style>
