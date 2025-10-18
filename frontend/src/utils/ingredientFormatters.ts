/**
 * Ingredient Display Formatters
 *
 * Utilities for formatting ingredient amounts in recipe displays.
 * These functions handle conversion between decimals and fractions,
 * volume to weight conversions, and proper spacing for different unit types.
 */

/**
 * Converts a decimal amount to a cooking-friendly fraction
 *
 * @param decimal - The decimal number to convert
 * @returns A string representing the fraction (e.g., "1/2", "2 3/4")
 *
 * @example
 * decimalToFraction(0.5) // "1/2"
 * decimalToFraction(2.75) // "2 3/4"
 * decimalToFraction(3) // "3"
 */
export function decimalToFraction(decimal: number): string {
  // Handle whole numbers
  if (decimal % 1 === 0) {
    return decimal.toString()
  }

  // Common cooking fractions
  const fractions: { [key: number]: string } = {
    0.125: '1/8',
    0.25: '1/4',
    0.333: '1/3',
    0.375: '3/8',
    0.5: '1/2',
    0.625: '5/8',
    0.666: '2/3',
    0.75: '3/4',
    0.875: '7/8',
  }

  // Check for whole number + fraction
  const whole = Math.floor(decimal)
  const fractional = Math.round((decimal - whole) * 1000) / 1000

  // Look for matching fraction
  for (const [key, value] of Object.entries(fractions)) {
    if (Math.abs(parseFloat(key) - fractional) < 0.01) {
      return whole > 0 ? `${whole} ${value}` : value
    }
  }

  return decimal.toString()
}

/**
 * Converts volume measurements (tsp/tbsp) to grams based on ingredient density
 *
 * @param amount - The quantity in teaspoons or tablespoons
 * @param unit - The unit of measurement ("tsp" or "tbsp")
 * @param ingredientName - The name of the ingredient (used to estimate density)
 * @returns The estimated weight in grams
 *
 * @example
 * convertToGrams(1, 'tsp', 'salt') // ~6g (1 tsp = 5ml, salt density ~1.2 g/ml)
 * convertToGrams(2, 'tbsp', 'olive oil') // ~28g (2 tbsp = 30ml, oil density ~0.92 g/ml)
 */
export function convertToGrams(amount: number, unit: string, ingredientName: string): number {
  // Convert to ml first
  let ml = 0
  if (unit === 'tsp' || unit === 'teaspoon' || unit === 'teaspoons') {
    ml = amount * 5
  } else if (unit === 'tbsp' || unit === 'tablespoon' || unit === 'tablespoons') {
    ml = amount * 15
  }

  // Estimate density based on ingredient type
  const normalized = ingredientName.toLowerCase()

  let densityGPerMl = 1.0 // default to water density

  if (normalized.includes('water') || normalized.includes('stock') || normalized.includes('broth')) {
    densityGPerMl = 1.0
  } else if (normalized.includes('milk') || normalized.includes('cream')) {
    densityGPerMl = 1.03
  } else if (normalized.includes('oil') || normalized.includes('butter')) {
    densityGPerMl = 0.92
  } else if (normalized.includes('honey') || normalized.includes('syrup')) {
    densityGPerMl = 1.4
  } else if (normalized.includes('flour')) {
    densityGPerMl = 0.5
  } else if (normalized.includes('sugar')) {
    densityGPerMl = 0.85
  } else if (normalized.includes('salt')) {
    densityGPerMl = 1.2
  } else if (normalized.includes('rice')) {
    densityGPerMl = 0.75
  } else if (normalized.includes('soy sauce') || normalized.includes('sauce')) {
    densityGPerMl = 1.1
  } else if (normalized.includes('vinegar')) {
    densityGPerMl = 1.0
  }

  return ml * densityGPerMl
}

/**
 * Formats an ingredient amount with appropriate unit and spacing
 *
 * Handles three main cases:
 * 1. Teaspoons/tablespoons: Shows fraction with grams in parentheses (e.g., "1/2 tsp (3g)")
 * 2. Whole items: Shows just the fraction without unit (e.g., "1/2" onion, "3" eggs)
 * 3. Other units: Shows amount with unit, using proper spacing rules
 *    - Metric units (no space): "300g", "500ml", "2kg"
 *    - Imperial units (space): "2 cups", "1 lb", "3 oz"
 *
 * @param amount - The numeric quantity
 * @param unit - The unit of measurement
 * @param ingredientName - The name of the ingredient (optional, used for density calculations)
 * @returns The formatted string for display
 *
 * @example
 * formatAmount(0.5, 'tsp', 'salt') // "1/2 tsp (6g)"
 * formatAmount(0.5, '', 'onion') // "1/2"
 * formatAmount(300, 'g', 'ground beef') // "300g"
 * formatAmount(2, 'cups', 'flour') // "2 cups"
 */
export function formatAmount(amount: number, unit: string, ingredientName: string = ''): string {
  const isTspOrTbsp = unit === 'tsp' || unit === 'tbsp' ||
                      unit === 'teaspoon' || unit === 'teaspoons' ||
                      unit === 'tablespoon' || unit === 'tablespoons'

  const isWholeUnit = unit === 'whole' || unit === 'piece' || unit === 'pieces' ||
                      unit === 'item' || unit === 'items' || unit === 'stalks' ||
                      unit === 'stalk' || unit === ''

  // Metric units that should have no space between amount and unit
  const metricUnits = ['g', 'kg', 'mg', 'ml', 'l', 'cl', 'dl']
  const isMetric = metricUnits.includes(unit.toLowerCase())

  // For tsp/tbsp, show fraction with grams and unit
  if (isTspOrTbsp) {
    const fraction = decimalToFraction(amount)
    const grams = convertToGrams(amount, unit, ingredientName)
    return `${fraction} ${unit} (${Math.round(grams)}g)`
  }

  // For whole items, just show fraction (no unit)
  if (isWholeUnit) {
    if (amount % 1 !== 0) {
      return decimalToFraction(amount)
    }
    return amount.toString()
  }

  // For metric units, no space between amount and unit
  if (isMetric) {
    return `${amount}${unit}`
  }

  // For imperial/other units (cups, lb, oz, etc.), add space
  return `${amount} ${unit}`
}
