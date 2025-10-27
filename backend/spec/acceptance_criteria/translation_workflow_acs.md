# Translation Workflow Acceptance Criteria

## System Overview

**Triggers:**
- Recipe create: immediate job enqueue
- Recipe update: deduped + rate-limited job enqueue
- Manual regeneration: bypasses all limits

**Rate Limiting:**
- Max: 4 translations per window (default)
- Window: 3600 seconds / 1 hour (default)
- Configurable via ENV

**Deduplication:**
- Deletes pending (non-claimed) jobs for same recipe on update
- Protects running (claimed) jobs from deletion

## Acceptance Criteria

### Job Enqueueing

**AC-TRANS-001: Immediate Job on Create**
- Given: new recipe is created
- When: recipe.save! completes
- Then: TranslateRecipeJob.perform_later(recipe.id) is called
- And: job is enqueued without delay

**AC-TRANS-002: Deduplication on Update - No Existing Job**
- Given: recipe with no pending translation jobs
- When: recipe is updated
- Then: new job is enqueued immediately
- And: no jobs are deleted

**AC-TRANS-003: Deduplication on Update - Pending Job Exists**
- Given: recipe with 1 pending (non-claimed) translation job
- When: recipe is updated
- Then: pending job is deleted
- And: new job is enqueued

**AC-TRANS-004: Deduplication on Update - Running Job Exists**
- Given: recipe with 1 running (claimed) translation job
- When: recipe is updated
- Then: running job is NOT deleted
- And: new job is enqueued

**AC-TRANS-005: Rate Limit Not Exceeded**
- Given: recipe has 3 completed jobs in last hour
- When: recipe is updated
- Then: new job is enqueued immediately (no delay)

**AC-TRANS-006: Rate Limit Exceeded - Delay Calculation**
- Given: recipe has 4 completed jobs in last hour at times [T1, T2, T3, T4]
- When: recipe is updated at time NOW
- Then: oldest job (T1) is identified
- And: next_available_time = T1 + 3600 seconds + 1 second
- And: delay = max(0, next_available_time - NOW)
- And: job is enqueued with .set(wait: delay.seconds)

**AC-TRANS-007: Manual Regeneration Bypasses All Logic**
- Given: recipe has 10 completed jobs in last hour
- And: recipe has 1 pending job
- When: admin calls /admin/recipes/:id/regenerate_translations
- Then: job is enqueued immediately via TranslateRecipeJob.perform_later(id)
- And: no deduplication occurs
- And: no rate limit check occurs

### Translation Execution

**AC-TRANS-008: Description Included in JSON Payload**
- Given: recipe with name="Test" and description="A test recipe"
- When: RecipeTranslator.build_recipe_json_for_translation(recipe)
- Then: JSON includes "name": "Test"
- And: JSON includes "description": "A test recipe"
- And: JSON includes ingredient_groups, steps, equipment

**AC-TRANS-009: All 6 Languages Translated**
- Given: recipe with source_language="en"
- When: TranslateRecipeJob.perform_now(recipe.id)
- Then: translator.translate_recipe is called 6 times
- And: target languages are: ja, ko, zh-tw, zh-cn, es, fr

**AC-TRANS-010: Description Saved to Translations Table**
- Given: Claude returns JSON with "description": "日本料理"
- When: apply_translations(recipe, translation_data, 'ja')
- Then: I18n.with_locale(:ja) { recipe.description } returns "日本料理"
- And: RecipeTranslation.find_by(recipe_id: recipe.id, locale: 'ja').description == "日本料理"

**AC-TRANS-011: All Fields Saved Atomically Per Language**
- Given: translation_data contains name, description, ingredient_groups, steps, equipment
- When: apply_translations(recipe, translation_data, 'ja')
- Then: recipe.name is updated
- And: recipe.description is updated
- And: ingredient names are updated
- And: step instructions are updated
- And: equipment names are updated
- And: all updates occur within I18n.with_locale(:ja) block

**AC-TRANS-012: Successful Completion Markers**
- Given: translation succeeds for all 6 languages
- When: TranslateRecipeJob.perform_now(recipe.id) completes
- Then: recipe.translations_completed == true
- And: recipe.last_translated_at is set to current time

**AC-TRANS-013: Partial Failure Markers**
- Given: translation succeeds for 5 languages but fails for 1
- When: TranslateRecipeJob.perform_now(recipe.id) completes
- Then: recipe.translations_completed == false
- And: recipe.last_translated_at is NOT updated
- And: successful translations are persisted

**AC-TRANS-014: Missing Recipe Graceful Failure**
- Given: recipe with id=999 does not exist
- When: TranslateRecipeJob.perform_now(999)
- Then: ActiveRecord::RecordNotFound is caught
- And: error is logged
- And: job does not raise exception

**AC-TRANS-015: Translation API Failure Handling**
- Given: RecipeTranslator.translate_recipe raises StandardError
- When: TranslateRecipeJob.perform_now(recipe.id)
- Then: error is logged for that language
- And: job continues to next language
- And: all_successful flag is set to false

### Edge Cases

**AC-TRANS-016: Empty Description Handling**
- Given: recipe with description=""
- When: translation job runs
- Then: empty description is sent to Claude
- And: translated empty description is saved (no nil errors)

**AC-TRANS-017: SolidQueue Not Available**
- Given: SolidQueue::Job table does not exist
- When: recipe is updated
- Then: job_queue_available? returns false
- And: deduplication is skipped
- And: rate limit checks are skipped
- And: job is enqueued immediately

**AC-TRANS-018: Rate Limit Window Expiry**
- Given: 4 jobs completed 61 minutes ago
- When: recipe is updated
- Then: completed_translation_job_count returns 0 (jobs outside window)
- And: rate limit is NOT exceeded
- And: job is enqueued immediately
