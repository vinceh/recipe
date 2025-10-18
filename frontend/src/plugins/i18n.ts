import { createI18n } from 'vue-i18n'

// Import locale messages
import en from '@/locales/en.json'
import ja from '@/locales/ja.json'
import ko from '@/locales/ko.json'
import zhTw from '@/locales/zh-tw.json'
import zhCn from '@/locales/zh-cn.json'
import es from '@/locales/es.json'
import fr from '@/locales/fr.json'

// Create i18n instance
export const i18n = createI18n({
  legacy: false, // Use Composition API mode
  locale: localStorage.getItem('locale') || navigator.language.split('-')[0] || 'en',
  fallbackLocale: 'en',
  messages: {
    en,
    ja,
    ko,
    'zh-tw': zhTw,
    'zh-cn': zhCn,
    es,
    fr
  },
  // Missing translation handler for development
  missing: (locale, key) => {
    if (import.meta.env.DEV) {
      console.warn(`[i18n] Missing translation: "${key}" for locale "${locale}"`)
      return `[${key}]` // Display missing key in brackets
    }
    return key
  }
})
