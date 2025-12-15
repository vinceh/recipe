/**
 * Recipe Scaler Engine
 *
 * Scales recipe ingredients based on serving adjustments with smart formatting.
 * Handles indivisible items (eggs, etc.) with practical equivalents.
 */

import type { RecipeIngredientGroup, RecipeIngredientItem } from '@/services/types'
import {
  formatScaledAmount,
  decimalToFraction,
  formatAmountWithUnit,
  roundToFriendlyFraction,
} from './measurementFormatter'
import { isCountUnit } from './unitConverter'

// Items that cannot be easily divided
const INDIVISIBLE_PATTERNS = [
  /^eggs?$/i,
  /^egg\s+(white|yolk)s?$/i,
  /^cloves?$/i,
  /^garlic\s+cloves?$/i,
  /^slices?$/i,
  /^fillets?$/i,
  /^breasts?$/i,
  /^thighs?$/i,
  /^drumsticks?$/i,
  /^wings?$/i,
  /^steaks?$/i,
  /^chops?$/i,
  /^whole$/i,
  /^head$/i,
  /^bunch(es)?$/i,
  /^cans?$/i,
  /^packets?$/i,
  /^packages?$/i,
  /^sheets?$/i, // pastry sheets
  /^sticks?$/i, // butter sticks, cinnamon sticks
]

// Items detected by name that are typically whole
const INDIVISIBLE_INGREDIENT_NAMES = [
  'egg',
  'eggs',
  'garlic',
  'onion',
  'shallot',
  'lemon',
  'lime',
  'orange',
  'apple',
  'banana',
  'avocado',
  'tomato',
  'potato',
  'carrot',
  'celery',
  'bay leaf',
  'bay leaves',
]

// Egg equivalent measurements for fractional eggs
const EGG_EQUIVALENTS: Record<string, string> = {
  '0.25': '≈1½ tsp beaten',
  '0.33': '≈1 tbsp beaten',
  '0.5': '≈1½ tbsp beaten',
  '0.66': '≈2 tbsp beaten',
  '0.75': '≈2½ tbsp beaten',
}

export interface ScaledIngredient {
  name: string
  displayAmount: string
  practicalAmount: string
  preciseAmount: string
  unit: string
  preparation?: string
  optional?: boolean
  isIndivisible: boolean
  equivalentNote?: string
  originalAmount?: string
  originalUnit?: string
}

export interface ScaledIngredientGroup {
  name: string
  items: ScaledIngredient[]
}

export interface ScaleOptions {
  requiresPrecision: boolean
  originalServings: number
  targetServings: number
}

/**
 * Check if an ingredient is indivisible based on its unit or name
 */
function isIndivisibleItem(name: string, unit: string): boolean {
  // Check unit patterns
  const normalizedUnit = unit.toLowerCase().trim()
  for (const pattern of INDIVISIBLE_PATTERNS) {
    if (pattern.test(normalizedUnit)) {
      return true
    }
  }

  // Check ingredient name
  const normalizedName = name.toLowerCase().trim()
  for (const indivisibleName of INDIVISIBLE_INGREDIENT_NAMES) {
    if (
      normalizedName === indivisibleName ||
      normalizedName.startsWith(indivisibleName + ' ') ||
      normalizedName.endsWith(' ' + indivisibleName)
    ) {
      return true
    }
  }

  // Check for common whole-item patterns in name
  if (/\b(whole|large|medium|small)\s+(egg|onion|garlic|lemon)/i.test(normalizedName)) {
    return true
  }

  return false
}

/**
 * Check if the ingredient is specifically an egg
 */
function isEggIngredient(name: string, unit: string): boolean {
  const normalizedName = name.toLowerCase()
  const normalizedUnit = unit.toLowerCase()

  return (
    /^eggs?$/i.test(normalizedUnit) ||
    normalizedName.includes('egg') ||
    /\beggs?\b/i.test(normalizedName)
  )
}

/**
 * Get equivalent note for fractional indivisible items (mainly eggs)
 */
function getEquivalentNote(
  scaledAmount: number,
  name: string,
  unit: string
): string | undefined {
  // Only provide equivalents for eggs
  if (!isEggIngredient(name, unit)) {
    return undefined
  }

  // Get the fractional part
  const fractional = scaledAmount - Math.floor(scaledAmount)
  if (fractional === 0) {
    return undefined
  }

  // Round to nearest common fraction for lookup
  const roundedFractional = Math.round(fractional * 100) / 100

  // Try exact match first
  const exactKey = roundedFractional.toFixed(2).replace(/\.?0+$/, '')
  if (EGG_EQUIVALENTS[exactKey]) {
    return EGG_EQUIVALENTS[exactKey]
  }

  // Try approximate matches
  for (const [key, value] of Object.entries(EGG_EQUIVALENTS)) {
    if (Math.abs(parseFloat(key) - fractional) < 0.1) {
      return value
    }
  }

  // Generic fallback for eggs
  const tbsp = Math.round(fractional * 3 * 10) / 10 // ~3 tbsp per egg
  if (tbsp > 0) {
    return `≈${tbsp} tbsp beaten`
  }

  return undefined
}

/**
 * Parse amount string to number
 * Handles fractions like "1/2", "1 1/2", "¼", etc.
 */
function parseAmount(amountStr: string | undefined): number {
  if (!amountStr) return 0

  const str = amountStr.trim()

  // Handle unicode fractions
  const unicodeFractions: Record<string, number> = {
    '⅛': 0.125,
    '¼': 0.25,
    '⅓': 0.333,
    '⅜': 0.375,
    '½': 0.5,
    '⅝': 0.625,
    '⅔': 0.666,
    '¾': 0.75,
    '⅞': 0.875,
  }

  // Check for unicode fraction at end (e.g., "2½")
  for (const [char, value] of Object.entries(unicodeFractions)) {
    if (str.endsWith(char)) {
      const whole = str.slice(0, -1).trim()
      return (whole ? parseFloat(whole) : 0) + value
    }
    if (str === char) {
      return value
    }
  }

  // Handle mixed numbers like "1 1/2"
  const mixedMatch = str.match(/^(\d+)\s+(\d+)\/(\d+)$/)
  if (mixedMatch && mixedMatch[1] && mixedMatch[2] && mixedMatch[3]) {
    const whole = parseInt(mixedMatch[1], 10)
    const num = parseInt(mixedMatch[2], 10)
    const denom = parseInt(mixedMatch[3], 10)
    return whole + num / denom
  }

  // Handle simple fractions like "1/2"
  const fractionMatch = str.match(/^(\d+)\/(\d+)$/)
  if (fractionMatch && fractionMatch[1] && fractionMatch[2]) {
    const num = parseInt(fractionMatch[1], 10)
    const denom = parseInt(fractionMatch[2], 10)
    return num / denom
  }

  // Handle decimal or whole number
  const parsed = parseFloat(str)
  return isNaN(parsed) ? 0 : parsed
}

/**
 * Scale a single ingredient
 */
function scaleIngredient(
  item: RecipeIngredientItem,
  scaleFactor: number,
  requiresPrecision: boolean
): ScaledIngredient {
  const originalAmount = parseAmount(item.amount)
  const originalUnit = item.unit || ''

  // If no original amount (e.g., "salt to taste"), return without scaling
  if (!item.amount || item.amount.trim() === '' || originalAmount === 0) {
    return {
      name: item.name,
      displayAmount: '',
      practicalAmount: '',
      preciseAmount: '',
      unit: originalUnit,
      preparation: item.preparation,
      optional: item.optional,
      isIndivisible: false,
      originalAmount: item.amount,
      originalUnit,
    }
  }

  const scaledAmount = originalAmount * scaleFactor

  const indivisible = isIndivisibleItem(item.name, originalUnit)

  // For indivisible items, show the fraction directly
  if (indivisible || isCountUnit(originalUnit)) {
    const { display } = roundToFriendlyFraction(scaledAmount)
    const equivalentNote = getEquivalentNote(scaledAmount, item.name, originalUnit)

    // Format display amount
    let displayAmount: string
    if (originalUnit && originalUnit !== '' && originalUnit !== 'whole') {
      displayAmount = formatAmountWithUnit(display, originalUnit)
    } else {
      displayAmount = display
    }

    return {
      name: item.name,
      displayAmount,
      practicalAmount: displayAmount,
      preciseAmount: displayAmount,
      unit: originalUnit,
      preparation: item.preparation,
      optional: item.optional,
      isIndivisible: indivisible,
      equivalentNote,
      originalAmount: item.amount,
      originalUnit,
    }
  }

  // For normal ingredients, use smart formatting
  const formatted = formatScaledAmount(
    scaledAmount,
    originalUnit,
    item.name,
    requiresPrecision
  )

  return {
    name: item.name,
    displayAmount: formatted.combined,
    practicalAmount: formatted.practical,
    preciseAmount: formatted.precise,
    unit: formatted.unit,
    preparation: item.preparation,
    optional: item.optional,
    isIndivisible: false,
    originalAmount: item.amount,
    originalUnit,
  }
}

/**
 * Scale all ingredients in a recipe
 */
export function scaleIngredients(
  groups: RecipeIngredientGroup[],
  options: ScaleOptions
): ScaledIngredientGroup[] {
  const { requiresPrecision, originalServings, targetServings } = options

  // Calculate scale factor
  const scaleFactor = targetServings / originalServings

  // Scale each group
  return groups.map((group) => ({
    name: group.name,
    items: group.items.map((item) =>
      scaleIngredient(item, scaleFactor, requiresPrecision)
    ),
  }))
}

/**
 * Get the scale factor between original and target servings
 */
export function getScaleFactor(
  originalServings: number,
  targetServings: number
): number {
  if (originalServings <= 0) return 1
  return targetServings / originalServings
}

/**
 * Format scale factor for display (e.g., "1.5×", "0.5×")
 */
export function formatScaleFactor(factor: number): string {
  if (factor === 1) return '1×'
  if (factor === 0.5) return '½×'
  if (factor === 1.5) return '1½×'
  if (factor === 2) return '2×'

  // Round to 1 decimal place
  const rounded = Math.round(factor * 10) / 10
  return `${rounded}×`
}
