#!/usr/bin/env node

/**
 * i18n Coverage Verification Script
 *
 * This script checks that all translation keys exist in ALL 7 locale files
 * Run before committing frontend changes to ensure 100% translation coverage
 *
 * Usage:
 *   node scripts/check-i18n-coverage.js
 *
 * Exit codes:
 *   0 - All translations present (100% coverage)
 *   1 - Missing translations detected
 */

import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const LOCALES_DIR = path.join(__dirname, '../src/locales');
const REQUIRED_LANGUAGES = ['en', 'ja', 'ko', 'zh-tw', 'zh-cn', 'es', 'fr'];

console.log('🌍 Checking i18n Translation Coverage...\n');

// Read all locale files
const locales = {};
for (const lang of REQUIRED_LANGUAGES) {
  const filePath = path.join(LOCALES_DIR, `${lang}.json`);

  if (!fs.existsSync(filePath)) {
    console.error(`❌ ERROR: Missing locale file: ${lang}.json`);
    process.exit(1);
  }

  try {
    locales[lang] = JSON.parse(fs.readFileSync(filePath, 'utf-8'));
  } catch (error) {
    console.error(`❌ ERROR: Failed to parse ${lang}.json:`, error.message);
    process.exit(1);
  }
}

console.log('✅ All 7 locale files found and parsed\n');

// Extract all keys from an object (nested)
function extractKeys(obj, prefix = '') {
  const keys = [];

  for (const [key, value] of Object.entries(obj)) {
    const fullKey = prefix ? `${prefix}.${key}` : key;

    if (typeof value === 'object' && value !== null && !Array.isArray(value)) {
      keys.push(...extractKeys(value, fullKey));
    } else {
      keys.push(fullKey);
    }
  }

  return keys;
}

// Get all keys from English (source of truth)
const englishKeys = extractKeys(locales.en);
console.log(`📊 Total translation keys in English: ${englishKeys.length}\n`);

// Check each language for missing keys
let allCovered = true;
const missingByLanguage = {};

for (const lang of REQUIRED_LANGUAGES) {
  if (lang === 'en') continue; // Skip English (it's the source)

  const langKeys = extractKeys(locales[lang]);
  const missing = englishKeys.filter(key => !langKeys.includes(key));

  if (missing.length > 0) {
    allCovered = false;
    missingByLanguage[lang] = missing;

    console.log(`❌ ${lang.toUpperCase()}: Missing ${missing.length} translations`);
    missing.forEach(key => {
      console.log(`   - ${key}`);
    });
    console.log('');
  } else {
    console.log(`✅ ${lang.toUpperCase()}: 100% coverage (${langKeys.length} keys)`);
  }
}

console.log('\n' + '='.repeat(60));

if (allCovered) {
  console.log('\n✅ SUCCESS: 100% translation coverage across all 7 languages!');
  console.log(`   Total keys: ${englishKeys.length}`);
  console.log('   Languages: en, ja, ko, zh-tw, zh-cn, es, fr\n');
  process.exit(0);
} else {
  console.log('\n❌ FAILED: Missing translations detected!');
  console.log('\n🔴 ACTION REQUIRED:');
  console.log('   1. Add missing translations to the locale files listed above');
  console.log('   2. Run this script again to verify');
  console.log('   3. DO NOT commit until all translations are present\n');
  console.log('See docs/i18n-workflow.md for guidance on adding translations.\n');
  process.exit(1);
}
