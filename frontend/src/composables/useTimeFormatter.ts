import { useI18n } from 'vue-i18n'

export interface TimeFormatter {
  formatTime: (minutes: number) => string
  formatTimeRange: (minMinutes: number, maxMinutes: number) => string
}

export function useTimeFormatter(): TimeFormatter {
  const { t } = useI18n()

  function formatTime(minutes: number): string {
    const minLabel = t('admin.recipes.table.minutes')
    const hourLabel = t('admin.recipes.table.hours')

    if (minutes < 60) {
      return `${minutes}${minLabel}`
    }
    const hours = Math.floor(minutes / 60)
    const mins = minutes % 60
    return mins > 0 ? `${hours}${hourLabel} ${mins}${minLabel}` : `${hours}${hourLabel}`
  }

  function formatTimeRange(minMinutes: number, maxMinutes: number): string {
    if (minMinutes === maxMinutes) {
      return formatTime(minMinutes)
    }
    return `${formatTime(minMinutes)} - ${formatTime(maxMinutes)}`
  }

  return {
    formatTime,
    formatTimeRange,
  }
}
