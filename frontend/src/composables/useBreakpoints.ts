/**
 * useBreakpoints Composable
 *
 * Provides reactive breakpoint detection for responsive design.
 * Returns boolean values indicating current screen size.
 *
 * Breakpoints:
 * - Mobile: < 768px
 * - Tablet: 768px - 1023px
 * - Desktop: >= 1024px
 *
 * Usage:
 * const { isMobile, isTablet, isDesktop } = useBreakpoints()
 *
 * if (isMobile.value) {
 *   // Mobile-specific logic
 * }
 */

import { ref, onMounted, onUnmounted, computed } from 'vue'

export interface Breakpoints {
  isMobile: ComputedRef<boolean>
  isTablet: ComputedRef<boolean>
  isDesktop: ComputedRef<boolean>
  screenWidth: Ref<number>
}

// Breakpoint definitions (matching CSS media queries)
const BREAKPOINTS = {
  mobile: 768,    // < 768px
  tablet: 1024    // < 1024px
} as const

export function useBreakpoints() {
  // Reactive screen width
  const screenWidth = ref(typeof window !== 'undefined' ? window.innerWidth : 1024)

  // Update screen width on resize
  const updateWidth = () => {
    screenWidth.value = window.innerWidth
  }

  // Computed breakpoint booleans
  const isMobile = computed(() => screenWidth.value < BREAKPOINTS.mobile)
  const isTablet = computed(() =>
    screenWidth.value >= BREAKPOINTS.mobile &&
    screenWidth.value < BREAKPOINTS.tablet
  )
  const isDesktop = computed(() => screenWidth.value >= BREAKPOINTS.tablet)

  // Set up resize listener
  onMounted(() => {
    window.addEventListener('resize', updateWidth)
  })

  // Clean up resize listener
  onUnmounted(() => {
    window.removeEventListener('resize', updateWidth)
  })

  return {
    isMobile,
    isTablet,
    isDesktop,
    screenWidth
  }
}

// Type exports
import type { Ref, ComputedRef } from 'vue'
