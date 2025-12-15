/**
 * Measurement Formatter for Recipe Scaling
 *
 * Converts raw scaled amounts into user-friendly cooking measurements
 * with practical amounts shown first and precise alternatives in parentheses.
 */

import {
  convert,
  toBaseUnit,
  isVolumeUnit,
  isWeightUnit,
  isCountUnit,
  normalizeUnit,
} from './unitConverter'

// Unicode fraction characters for clean display
// Only practical fractions that can be measured with standard tools
const FRACTION_CHARS: Record<number, string> = {
  0.25: '¼',
  0.333: '⅓',
  0.5: '½',
  0.666: '⅔',
  0.75: '¾',
}

// Tolerance for matching fractions
const FRACTION_TOLERANCE = 0.06

// Measurable metric increments (what kitchen scales/measuring tools can do)
const METRIC_INCREMENTS = [5, 10, 15, 25, 50, 75, 100, 125, 150, 200, 250, 300, 400, 500]

// Ingredient density estimates (g/ml) for volume-to-weight conversion
const INGREDIENT_DENSITIES: Record<string, number> = {
  water: 1.0,
  stock: 1.0,
  broth: 1.0,
  milk: 1.03,
  cream: 1.0,
  oil: 0.92,
  'olive oil': 0.92,
  butter: 0.96,
  honey: 1.4,
  syrup: 1.4,
  'maple syrup': 1.37,
  flour: 0.53,
  'all-purpose flour': 0.53,
  'bread flour': 0.55,
  sugar: 0.85,
  'brown sugar': 0.82,
  'powdered sugar': 0.56,
  salt: 1.2,
  'kosher salt': 0.58,
  'sea salt': 1.15,
  rice: 0.75,
  'soy sauce': 1.1,
  vinegar: 1.0,
  'fish sauce': 1.12,
  cocoa: 0.4,
  'cocoa powder': 0.4,
  cornstarch: 0.54,
  'baking powder': 0.9,
  'baking soda': 1.1,
  yeast: 0.72,
  oats: 0.4,
  'rolled oats': 0.4,
}

/**
 * Round a decimal to the nearest friendly cooking fraction
 */
export function roundToFriendlyFraction(decimal: number): {
  value: number
  display: string
} {
  // Handle whole numbers
  if (decimal % 1 === 0) {
    return { value: decimal, display: decimal.toString() }
  }

  const whole = Math.floor(decimal)
  const fractional = decimal - whole

  // Try to match a friendly fraction
  for (const [key, char] of Object.entries(FRACTION_CHARS)) {
    const fractionValue = parseFloat(key)
    if (Math.abs(fractional - fractionValue) < FRACTION_TOLERANCE) {
      const roundedValue = whole + fractionValue
      const display = whole > 0 ? `${whole}${char}` : char
      return { value: roundedValue, display }
    }
  }

  // No match - round to nearest 0.25
  const roundedFractional = Math.round(fractional * 4) / 4
  if (roundedFractional === 0) {
    return { value: whole, display: whole.toString() }
  }
  if (roundedFractional === 1) {
    return { value: whole + 1, display: (whole + 1).toString() }
  }

  // Use fraction char if available
  const fractionChar = FRACTION_CHARS[roundedFractional]
  if (fractionChar) {
    const display = whole > 0 ? `${whole}${fractionChar}` : fractionChar
    return { value: whole + roundedFractional, display }
  }

  // Fallback to decimal with 1 decimal place
  const roundedDecimal = Math.round(decimal * 10) / 10
  return { value: roundedDecimal, display: roundedDecimal.toString() }
}

/**
 * Convert decimal to display fraction (simpler version for specific use cases)
 */
export function decimalToFraction(decimal: number): string {
  return roundToFriendlyFraction(decimal).display
}

/**
 * Round metric amounts (ml, g) to measurable increments
 * 52ml → 50ml, 127g → 125g, 3ml → 5ml
 */
export function roundToMeasurableMetric(amount: number): number {
  if (amount <= 0) return 0
  if (amount < 5) return 5

  const firstIncrement = METRIC_INCREMENTS[0]
  const lastIncrement = METRIC_INCREMENTS[METRIC_INCREMENTS.length - 1]

  // Safety check (should never happen with our constant array)
  if (firstIncrement === undefined || lastIncrement === undefined) {
    return Math.round(amount / 5) * 5
  }

  // For amounts larger than max increment, round to nearest 50
  if (amount > lastIncrement) {
    return Math.round(amount / 50) * 50
  }

  // Find the nearest increment
  let closest = firstIncrement
  let minDiff = Math.abs(amount - closest)

  for (const increment of METRIC_INCREMENTS) {
    const diff = Math.abs(amount - increment)
    if (diff < minDiff) {
      minDiff = diff
      closest = increment
    }
  }

  return closest
}

/**
 * Step down a unit to a more practical measurement when amount is too small
 *
 * Rules:
 * - < 1 tbsp → tsp
 * - < 0.25 cup → tbsp
 * - < 1 tsp → ml (if very small)
 */
export function stepDownUnit(
  amount: number,
  unit: string
): { amount: number; unit: string } {
  const normalized = normalizeUnit(unit)

  // Cup to tbsp when < 0.25 cup
  if ((normalized === 'cup' || normalized === 'cups') && amount < 0.25) {
    const tbspAmount = convert(amount, 'cup', 'tbsp')
    if (tbspAmount !== null) {
      return { amount: tbspAmount, unit: 'tbsp' }
    }
  }

  // Tbsp to tsp when < 1 tbsp
  if (
    (normalized === 'tbsp' || normalized === 'tablespoon' || normalized === 'tablespoons') &&
    amount < 1
  ) {
    const tspAmount = convert(amount, 'tbsp', 'tsp')
    if (tspAmount !== null) {
      return { amount: tspAmount, unit: 'tsp' }
    }
  }

  // Very small tsp amounts stay as tsp (don't go to ml for cooking)
  return { amount, unit }
}

/**
 * Step up a unit to avoid large numbers
 *
 * Rules:
 * - > 3 tsp → tbsp
 * - > 4 tbsp → cup (quarter cup)
 * - > 1000g → kg
 * - > 1000ml → l
 */
export function stepUpUnit(
  amount: number,
  unit: string
): { amount: number; unit: string } {
  const normalized = normalizeUnit(unit)

  // tsp to tbsp when >= 3 tsp
  if (
    (normalized === 'tsp' || normalized === 'teaspoon' || normalized === 'teaspoons') &&
    amount >= 3
  ) {
    const tbspAmount = convert(amount, 'tsp', 'tbsp')
    if (tbspAmount !== null && tbspAmount >= 1) {
      return { amount: tbspAmount, unit: 'tbsp' }
    }
  }

  // tbsp to cup when >= 4 tbsp (1/4 cup)
  if (
    (normalized === 'tbsp' || normalized === 'tablespoon' || normalized === 'tablespoons') &&
    amount >= 4
  ) {
    const cupAmount = convert(amount, 'tbsp', 'cup')
    if (cupAmount !== null && cupAmount >= 0.25) {
      return { amount: cupAmount, unit: 'cup' }
    }
  }

  // g to kg when >= 1000g
  if (normalized === 'g' && amount >= 1000) {
    return { amount: amount / 1000, unit: 'kg' }
  }

  // ml to l when >= 1000ml
  if (normalized === 'ml' && amount >= 1000) {
    return { amount: amount / 1000, unit: 'l' }
  }

  return { amount, unit }
}

/**
 * Get the best practical measurement (step down/up as needed)
 */
export function getPracticalMeasurement(
  amount: number,
  unit: string
): { amount: number; unit: string; display: string } {
  // First try stepping down
  let result = stepDownUnit(amount, unit)

  // Then try stepping up
  result = stepUpUnit(result.amount, result.unit)

  const normalized = normalizeUnit(result.unit)
  const metricUnits = ['g', 'kg', 'mg', 'ml', 'l', 'cl', 'dl']

  // For metric units, round to measurable increments (always whole numbers)
  if (metricUnits.includes(normalized)) {
    const roundedAmount = roundToMeasurableMetric(result.amount)
    return {
      amount: roundedAmount,
      unit: result.unit,
      display: formatAmountWithUnit(roundedAmount, result.unit),
    }
  }

  // For non-metric units, round to friendly fraction
  const rounded = roundToFriendlyFraction(result.amount)

  return {
    amount: rounded.value,
    unit: result.unit,
    display: formatAmountWithUnit(rounded.display, result.unit),
  }
}

/**
 * Estimate ingredient density for volume-to-weight conversion
 * Returns null if density is unknown (no guessing)
 */
function getIngredientDensity(ingredientName: string): number | null {
  const normalized = ingredientName.toLowerCase()

  // Check exact matches first
  if (INGREDIENT_DENSITIES[normalized]) {
    return INGREDIENT_DENSITIES[normalized]
  }

  // Check partial matches
  for (const [key, density] of Object.entries(INGREDIENT_DENSITIES)) {
    if (normalized.includes(key) || key.includes(normalized)) {
      return density
    }
  }

  // Unknown density - don't guess
  return null
}

/**
 * Convert volume measurement to grams estimate
 * Returns null if density is unknown for the ingredient
 */
export function estimateGrams(
  amount: number,
  unit: string,
  ingredientName: string
): number | null {
  const base = toBaseUnit(amount, unit)
  if (!base || base.baseUnit !== 'ml') return null

  const density = getIngredientDensity(ingredientName)
  if (density === null) return null

  return Math.round(base.amount * density)
}

/**
 * Format amount with unit, applying proper spacing rules
 *
 * - Metric units (no space): "300g", "500ml"
 * - Imperial/other units (space): "2 cups", "1 lb"
 */
export function formatAmountWithUnit(amount: string | number, unit: string): string {
  const amountStr = typeof amount === 'number' ? amount.toString() : amount
  const normalized = normalizeUnit(unit)

  // No unit
  if (!unit || normalized === '' || normalized === 'whole') {
    return amountStr
  }

  // Metric units - no space
  const metricUnits = ['g', 'kg', 'mg', 'ml', 'l', 'cl', 'dl']
  if (metricUnits.includes(normalized)) {
    return `${amountStr}${unit}`
  }

  // Everything else - with space
  return `${amountStr} ${unit}`
}

export interface FormattedMeasurement {
  practical: string // "2¼ tsp"
  precise: string // "11g"
  combined: string // "2¼ tsp (11g)"
  rawAmount: number
  unit: string
}

/**
 * Round ml amounts: <20 round to nearest 1, >=20 round to nearest 5
 */
function roundMl(amount: number): number {
  if (amount < 20) {
    return Math.round(amount)
  }
  return Math.round(amount / 5) * 5
}

/**
 * Format a scaled ingredient amount with both practical and precise measurements
 *
 * - ml/l: Round ml (<20 → nearest 1, >=20 → nearest 5), show grams in parentheses
 * - tbsp/tsp/cup: Smart step-down/up conversion, show grams in parentheses
 * - Weight: Show as-is (rounded to whole number)
 * - Count: Show as friendly fractions
 *
 * @param amount - The raw scaled amount
 * @param unit - The original unit
 * @param ingredientName - Name of ingredient (for density estimation)
 * @param requiresPrecision - If true, skip friendly conversions
 */
/**
 * Simple format for displaying ingredient amounts (backward compatible with old API)
 * @deprecated Use formatScaledAmount for richer formatting
 */
export function formatAmount(amount: number, unit: string, ingredientName: string = ''): string {
  return formatScaledAmount(amount, unit, ingredientName).practical
}

export function formatScaledAmount(
  amount: number,
  unit: string,
  ingredientName: string,
  requiresPrecision: boolean = false
): FormattedMeasurement {
  const normalized = normalizeUnit(unit)

  // Precision mode: just show exact value
  if (requiresPrecision) {
    const rounded = Math.round(amount * 100) / 100
    const display = formatAmountWithUnit(rounded, unit)
    return {
      practical: display,
      precise: display,
      combined: display,
      rawAmount: amount,
      unit,
    }
  }

  // Metric volume units (ml, l): round appropriately, show grams in parentheses
  if (normalized === 'ml' || normalized === 'l' || normalized === 'cl' || normalized === 'dl') {
    const base = toBaseUnit(amount, unit)
    if (base) {
      const mlRounded = roundMl(base.amount)
      const practical = `${mlRounded}ml`

      const grams = estimateGrams(amount, unit, ingredientName)
      const precise = grams !== null && grams > 0 ? `${Math.round(grams)}g` : practical

      const combined = precise !== practical ? `${practical} (${precise})` : practical

      return {
        practical,
        precise,
        combined,
        rawAmount: amount,
        unit: 'ml',
      }
    }
  }

  // Imperial volume units (tbsp, tsp, cup): smart step-down/up, show grams in parentheses
  if (isVolumeUnit(unit)) {
    const practical = getPracticalMeasurement(amount, unit)

    const grams = estimateGrams(amount, unit, ingredientName)
    const precise = grams !== null && grams > 0 ? `${Math.round(grams)}g` : practical.display

    const combined = precise !== practical.display ? `${practical.display} (${precise})` : practical.display

    return {
      practical: practical.display,
      precise,
      combined,
      rawAmount: amount,
      unit: practical.unit,
    }
  }

  // Weight units: show as-is with rounding
  if (isWeightUnit(unit)) {
    const base = toBaseUnit(amount, unit)
    if (base && base.baseUnit === 'g') {
      const gRounded = Math.round(base.amount)
      const display = `${gRounded}g`
      return {
        practical: display,
        precise: display,
        combined: display,
        rawAmount: amount,
        unit: 'g',
      }
    }
  }

  // Count units: show as friendly fractions
  const rounded = roundToFriendlyFraction(amount)
  const display = formatAmountWithUnit(rounded.display, unit)

  return {
    practical: display,
    precise: display,
    combined: display,
    rawAmount: amount,
    unit,
  }
}
