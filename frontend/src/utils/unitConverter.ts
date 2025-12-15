/**
 * Unit Converter for Recipe Scaling
 *
 * Provides conversion between cooking measurement units with support for
 * both volume (cup, tbsp, tsp, ml) and weight (kg, lb, oz, g) units.
 */

type UnitType = 'volume' | 'weight' | 'count' | 'unknown'

interface ConversionFactor {
  [toUnit: string]: number
}

interface ConversionTable {
  [fromUnit: string]: ConversionFactor
}

// Volume conversions (all relative to ml as base)
const VOLUME_TO_ML: Record<string, number> = {
  ml: 1,
  l: 1000,
  cl: 10,
  dl: 100,
  cup: 240,
  cups: 240,
  tbsp: 15,
  tablespoon: 15,
  tablespoons: 15,
  tsp: 5,
  teaspoon: 5,
  teaspoons: 5,
  'fl oz': 29.5735,
  'fluid ounce': 29.5735,
  'fluid ounces': 29.5735,
}

// Weight conversions (all relative to g as base)
const WEIGHT_TO_G: Record<string, number> = {
  g: 1,
  kg: 1000,
  mg: 0.001,
  lb: 453.592,
  lbs: 453.592,
  pound: 453.592,
  pounds: 453.592,
  oz: 28.3495,
  ounce: 28.3495,
  ounces: 28.3495,
}

// Count/whole item units (no conversion, just pass through)
const COUNT_UNITS = new Set([
  '', 'whole', 'piece', 'pieces', 'item', 'items',
  'clove', 'cloves', 'slice', 'slices', 'stalk', 'stalks',
  'sprig', 'sprigs', 'bunch', 'bunches', 'head', 'heads',
  'leaf', 'leaves', 'pinch', 'pinches', 'dash', 'dashes',
  'can', 'cans', 'packet', 'packets', 'package', 'packages',
])

/**
 * Normalize unit string to lowercase and handle common variations
 */
export function normalizeUnit(unit: string): string {
  return unit.toLowerCase().trim()
}

/**
 * Determine the type of a unit
 */
export function getUnitType(unit: string): UnitType {
  const normalized = normalizeUnit(unit)

  if (normalized in VOLUME_TO_ML) return 'volume'
  if (normalized in WEIGHT_TO_G) return 'weight'
  if (COUNT_UNITS.has(normalized)) return 'count'

  return 'unknown'
}

/**
 * Check if conversion between two units is possible
 */
export function canConvert(fromUnit: string, toUnit: string): boolean {
  const fromType = getUnitType(fromUnit)
  const toType = getUnitType(toUnit)

  // Can only convert within same type
  return fromType === toType && fromType !== 'unknown'
}

/**
 * Convert an amount from one unit to another
 * Returns null if conversion is not possible
 */
export function convert(
  amount: number,
  fromUnit: string,
  toUnit: string
): number | null {
  const fromNorm = normalizeUnit(fromUnit)
  const toNorm = normalizeUnit(toUnit)

  // Same unit, no conversion needed
  if (fromNorm === toNorm) return amount

  const fromType = getUnitType(fromUnit)
  const toType = getUnitType(toUnit)

  // Can't convert between different types
  if (fromType !== toType) return null

  // Count units can't be converted to each other
  if (fromType === 'count') return null

  if (fromType === 'volume') {
    const fromFactor = VOLUME_TO_ML[fromNorm]
    const toFactor = VOLUME_TO_ML[toNorm]
    if (fromFactor === undefined || toFactor === undefined) return null
    return (amount * fromFactor) / toFactor
  }

  if (fromType === 'weight') {
    const fromFactor = WEIGHT_TO_G[fromNorm]
    const toFactor = WEIGHT_TO_G[toNorm]
    if (fromFactor === undefined || toFactor === undefined) return null
    return (amount * fromFactor) / toFactor
  }

  return null
}

/**
 * Convert to base unit (ml for volume, g for weight)
 */
export function toBaseUnit(
  amount: number,
  unit: string
): { amount: number; baseUnit: string } | null {
  const normalized = normalizeUnit(unit)
  const unitType = getUnitType(unit)

  if (unitType === 'volume') {
    const factor = VOLUME_TO_ML[normalized]
    if (factor === undefined) return null
    return {
      amount: amount * factor,
      baseUnit: 'ml',
    }
  }

  if (unitType === 'weight') {
    const factor = WEIGHT_TO_G[normalized]
    if (factor === undefined) return null
    return {
      amount: amount * factor,
      baseUnit: 'g',
    }
  }

  // For count units, return as-is
  if (unitType === 'count') {
    return { amount, baseUnit: unit }
  }

  return null
}

/**
 * Convert from base unit to target unit
 */
export function fromBaseUnit(
  amount: number,
  baseUnit: string,
  targetUnit: string
): number | null {
  const targetNorm = normalizeUnit(targetUnit)

  if (baseUnit === 'ml') {
    const factor = VOLUME_TO_ML[targetNorm]
    if (factor === undefined) return null
    return amount / factor
  }

  if (baseUnit === 'g') {
    const factor = WEIGHT_TO_G[targetNorm]
    if (factor === undefined) return null
    return amount / factor
  }

  return null
}

/**
 * Get the ml equivalent for a volume unit (1 unit = X ml)
 */
export function getMlEquivalent(unit: string): number | null {
  const normalized = normalizeUnit(unit)
  return VOLUME_TO_ML[normalized] ?? null
}

/**
 * Get the gram equivalent for a weight unit (1 unit = X g)
 */
export function getGramEquivalent(unit: string): number | null {
  const normalized = normalizeUnit(unit)
  return WEIGHT_TO_G[normalized] ?? null
}

/**
 * Check if a unit is a volume measurement
 */
export function isVolumeUnit(unit: string): boolean {
  return getUnitType(unit) === 'volume'
}

/**
 * Check if a unit is a weight measurement
 */
export function isWeightUnit(unit: string): boolean {
  return getUnitType(unit) === 'weight'
}

/**
 * Check if a unit is a count/whole item measurement
 */
export function isCountUnit(unit: string): boolean {
  return getUnitType(unit) === 'count'
}

/**
 * Get all available volume units
 */
export function getVolumeUnits(): string[] {
  return Object.keys(VOLUME_TO_ML)
}

/**
 * Get all available weight units
 */
export function getWeightUnits(): string[] {
  return Object.keys(WEIGHT_TO_G)
}
