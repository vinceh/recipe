import type { RecipeDetail, RecipeIngredientGroup, RecipeIngredientItem, RecipeStep } from '@/services/types'

interface IngredientWithDisplay extends RecipeIngredientItem {
  displayAmount: string
}

function formatIngredientAmount(amount?: string, unit?: string): string {
  if (!amount) return ''
  return unit ? `${amount} ${unit}` : amount
}

/**
 * Normalize a string for comparison (lowercase, trim whitespace)
 */
function normalizeString(str: string): string {
  return str.toLowerCase().trim()
}

/**
 * Calculate similarity between two strings using Levenshtein distance ratio
 * Returns a value between 0 (completely different) and 1 (identical)
 */
function calculateSimilarity(str1: string, str2: string): number {
  const s1 = normalizeString(str1)
  const s2 = normalizeString(str2)

  if (s1 === s2) return 1
  if (s1.length === 0 || s2.length === 0) return 0

  const maxLen = Math.max(s1.length, s2.length)
  const distance = levenshteinDistance(s1, s2)
  return 1 - distance / maxLen
}

/**
 * Levenshtein distance implementation
 */
function levenshteinDistance(str1: string, str2: string): number {
  const m = str1.length
  const n = str2.length
  const dp: number[][] = Array(m + 1).fill(null).map(() => Array(n + 1).fill(0))

  for (let i = 0; i <= m; i++) dp[i][0] = i
  for (let j = 0; j <= n; j++) dp[0][j] = j

  for (let i = 1; i <= m; i++) {
    for (let j = 1; j <= n; j++) {
      if (str1[i - 1] === str2[j - 1]) {
        dp[i][j] = dp[i - 1][j - 1]
      } else {
        dp[i][j] = 1 + Math.min(dp[i - 1][j], dp[i][j - 1], dp[i - 1][j - 1])
      }
    }
  }

  return dp[m][n]
}

/**
 * Find the best matching original ingredient for a current ingredient
 * Uses exact name match first, then falls back to fuzzy matching
 */
export function findMatchingIngredient(
  currentItem: RecipeIngredientItem,
  originalGroups: RecipeIngredientGroup[] | undefined
): IngredientWithDisplay | null {
  if (!originalGroups) return null

  const currentName = normalizeString(currentItem.name)
  let bestMatch: RecipeIngredientItem | null = null
  let bestSimilarity = 0

  // Search through all original groups and items
  for (const group of originalGroups) {
    if (!group.items) continue

    for (const originalItem of group.items) {
      const originalName = normalizeString(originalItem.name)

      // Exact match
      if (currentName === originalName) {
        return {
          ...originalItem,
          displayAmount: formatIngredientAmount(originalItem.amount?.toString(), originalItem.unit)
        }
      }

      // Calculate similarity for fuzzy matching
      const similarity = calculateSimilarity(currentItem.name, originalItem.name)
      if (similarity > bestSimilarity && similarity > 0.6) {
        bestSimilarity = similarity
        bestMatch = originalItem
      }
    }
  }

  if (bestMatch) {
    return {
      ...bestMatch,
      displayAmount: formatIngredientAmount(bestMatch.amount?.toString(), bestMatch.unit)
    }
  }

  return null
}

/**
 * Find the best matching original step for a current step
 * Uses fuzzy string matching since step instructions may be modified
 */
export function findMatchingStep(
  currentStep: RecipeStep,
  originalSteps: RecipeStep[] | undefined
): RecipeStep | null {
  if (!originalSteps || originalSteps.length === 0) return null

  const currentInstruction = currentStep.instruction
  let bestMatch: RecipeStep | null = null
  let bestSimilarity = 0

  for (const originalStep of originalSteps) {
    const similarity = calculateSimilarity(currentInstruction, originalStep.instruction)

    // High threshold to avoid false matches
    if (similarity > bestSimilarity && similarity > 0.5) {
      bestSimilarity = similarity
      bestMatch = originalStep
    }
  }

  return bestMatch
}

/**
 * Create a diff-aware ingredient lookup function
 * Returns a function that finds the matching original ingredient for any current ingredient
 */
export function createIngredientMatcher(previousRecipe: RecipeDetail | null) {
  return function getOriginalIngredient(
    currentGroups: RecipeIngredientGroup[] | undefined,
    groupIndex: number,
    itemIndex: number
  ): IngredientWithDisplay | null {
    if (!previousRecipe?.ingredient_groups) return null
    if (!currentGroups) return null

    const currentGroup = currentGroups[groupIndex]
    if (!currentGroup?.items) return null

    const currentItem = currentGroup.items[itemIndex]
    if (!currentItem) return null

    return findMatchingIngredient(currentItem, previousRecipe.ingredient_groups)
  }
}

/**
 * Create a diff-aware step lookup function
 * Returns a function that finds the matching original step for any current step
 */
export function createStepMatcher(previousRecipe: RecipeDetail | null) {
  return function getOriginalStep(
    currentSteps: RecipeStep[] | undefined,
    stepIndex: number
  ): RecipeStep | null {
    if (!previousRecipe?.steps) return null
    if (!currentSteps) return null

    const currentStep = currentSteps[stepIndex]
    if (!currentStep) return null

    return findMatchingStep(currentStep, previousRecipe.steps)
  }
}
