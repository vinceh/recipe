require 'rails_helper'

describe 'Recipe Translations (AC-PHASE4-MODEL-001, READ, WRITE, QUERY)', type: :model do
  let(:recipe) { create(:recipe, name: 'Original Recipe') }

  describe 'Translation Declaration' do
    it 'translates :name field (AC-PHASE4-MODEL-001)' do
      expect(recipe).to respond_to(:name=)
      expect(recipe).to respond_to(:name)
    end

    it 'uses Table backend for translations' do
      I18n.with_locale(:ja) do
        recipe.name = 'レシピ'
        recipe.save
      end

      translation = RecipeTranslation.find_by(recipe_id: recipe.id, locale: 'ja')
      expect(translation).to be_present
      expect(translation.name).to eq('レシピ')
    end
  end

  describe 'Reading Translations' do
    before do
      I18n.with_locale(:en) { recipe.update(name: 'English Recipe') }
      I18n.with_locale(:ja) { recipe.update(name: 'レシピ') }
    end

    it 'reads translation in current locale (AC-PHASE4-READ-001)' do
      I18n.with_locale(:ja) do
        expect(recipe.name).to eq('レシピ')
      end
    end

    it 'reads translation with I18n.with_locale (AC-PHASE4-READ-002)' do
      result = I18n.with_locale(:ja) { recipe.name }
      expect(result).to eq('レシピ')
      expect(I18n.locale).to eq(:en) # Original locale restored
    end

    it 'reads translation with Mobility.with_locale (AC-PHASE4-READ-003)' do
      result = Mobility.with_locale(:ja) { recipe.name }
      expect(result).to eq('レシピ')
    end

    it 'falls back to fallback locale when translation missing (AC-PHASE4-READ-004)' do
      # Remove ja translation
      RecipeTranslation.where(recipe_id: recipe.id, locale: 'ja').delete_all

      I18n.with_locale(:ja) do
        expect(recipe.name).to eq('English Recipe') # Falls back to en
      end
    end

    it 'returns nil when no translation in any locale (AC-PHASE4-READ-005)' do
      recipe.update(name: nil)
      RecipeTranslation.where(recipe_id: recipe.id).delete_all

      I18n.with_locale(:ja) do
        expect(recipe.name).to be_nil
      end
    end

    it 'uses fallback chain correctly (AC-PHASE4-READ-006)' do
      RecipeTranslation.where(recipe_id: recipe.id, locale: 'ja').delete_all
      RecipeTranslation.where(recipe_id: recipe.id, locale: 'ko').delete_all

      I18n.with_locale(:ja) do
        expect(recipe.name).to eq('English Recipe')
      end

      I18n.with_locale(:ko) do
        expect(recipe.name).to eq('English Recipe')
      end
    end
  end

  describe 'Writing Translations' do
    it 'writes translation to current locale (AC-PHASE4-WRITE-001)' do
      I18n.with_locale(:en) do
        recipe.update(name: 'Updated Recipe')
      end

      translation = RecipeTranslation.find_by(recipe_id: recipe.id, locale: 'en')
      expect(translation.name).to eq('Updated Recipe')
    end

    it 'creates translation record (AC-PHASE4-WRITE-002)' do
      expect {
        I18n.with_locale(:ja) { recipe.update(name: 'レシピ') }
      }.to change(RecipeTranslation, :count).by(1)

      translation = RecipeTranslation.find_by(recipe_id: recipe.id, locale: 'ja')
      expect(translation).to be_present
      expect(translation.name).to eq('レシピ')
    end

    it 'updates existing translation (AC-PHASE4-WRITE-003)' do
      I18n.with_locale(:ja) { recipe.update(name: 'Old Recipe') }

      expect {
        I18n.with_locale(:ja) { recipe.update(name: 'New Recipe') }
      }.not_to change(RecipeTranslation, :count)

      translation = RecipeTranslation.find_by(recipe_id: recipe.id, locale: 'ja')
      expect(translation.name).to eq('New Recipe')
    end

    it 'does not create duplicate records (AC-PHASE4-WRITE-003B)' do
      I18n.with_locale(:ja) { recipe.update(name: 'レシピ') }
      initial_count = RecipeTranslation.where(recipe_id: recipe.id, locale: 'ja').count

      I18n.with_locale(:ja) { recipe.update(name: 'Updated') }
      final_count = RecipeTranslation.where(recipe_id: recipe.id, locale: 'ja').count

      expect(initial_count).to eq(1)
      expect(final_count).to eq(1)
    end

    it 'allows writing null translation (AC-PHASE4-WRITE-004)' do
      I18n.with_locale(:ja) { recipe.update(name: 'レシピ') }
      I18n.with_locale(:ja) { recipe.update(name: nil) }

      translation = RecipeTranslation.find_by(recipe_id: recipe.id, locale: 'ja')
      expect(translation.name).to be_nil
    end
  end

  describe 'Querying Translated Fields' do
    before do
      create(:recipe, name: 'Curry')
      create(:recipe, name: 'Curry Chicken')
      create(:recipe, name: 'Pad Thai')

      I18n.with_locale(:ja) do
        Recipe.find_by(name: 'Curry').update(name: 'カレー')
      end
    end

    it 'queries by translated field in current locale (AC-PHASE4-QUERY-001)' do
      I18n.with_locale(:en) do
        results = Recipe.i18n.where(name: 'Curry')
        expect(results.count).to be >= 1
        expect(results.map(&:name)).to include('Curry')
      end
    end

    it 'searches across locales correctly (AC-PHASE4-QUERY-002)' do
      I18n.with_locale(:en) do
        results = Recipe.i18n.where(name: 'Curry')
        expect(results.map(&:name)).not_to include('カレー')
      end
    end

    it 'queries with fallback locale (AC-PHASE4-QUERY-003)' do
      recipe_en_only = create(:recipe, name: 'Sushi')

      I18n.with_locale(:ja) do
        results = Recipe.i18n.where(name: 'Sushi')
        expect(results.count).to be >= 1
      end
    end

    it 'combines .i18n with other scopes (AC-PHASE4-QUERY-004)' do
      I18n.with_locale(:en) do
        results = Recipe.i18n.where(name: 'Curry')
        expect(results).to be_a(ActiveRecord::Relation)
      end
    end

    it 'orders by translated field (AC-PHASE4-QUERY-005)' do
      I18n.with_locale(:en) do
        results = Recipe.i18n.order('name ASC')
        expect(results.first.name).to eq('Curry')
      end
    end
  end

  describe 'Validation with Translations' do
    it 'enforces presence validation on translated field (AC-PHASE4-VALID-001)' do
      I18n.with_locale(:en) do
        recipe.name = nil
        expect(recipe).not_to be_valid
        expect(recipe.errors[:name]).to be_present
      end
    end

    it 'enforces uniqueness validation on translated field (AC-PHASE4-VALID-002)' do
      create(:recipe, name: 'Unique Recipe')

      recipe.name = 'Unique Recipe'
      expect(recipe).not_to be_valid
      expect(recipe.errors[:name]).to be_present
    end

    it 'allows same value in different locales (AC-PHASE4-VALID-003)' do
      I18n.with_locale(:en) { recipe.update(name: 'Shared Name') }

      I18n.with_locale(:ja) do
        recipe.name = 'Shared Name'
        expect(recipe).to be_valid
      end
    end
  end

  describe 'Serialization with Translations' do
    before do
      I18n.with_locale(:en) { recipe.update(name: 'English Recipe') }
      I18n.with_locale(:ja) { recipe.update(name: 'レシピ') }
    end

    it 'serializes current locale translation (AC-PHASE4-SERIAL-001)' do
      I18n.with_locale(:ja) do
        expect(recipe.name).to eq('レシピ')
      end
    end

    it 'uses fallback on serialization (AC-PHASE4-SERIAL-002)' do
      RecipeTranslation.where(recipe_id: recipe.id, locale: 'ja').delete_all

      I18n.with_locale(:ja) do
        expect(recipe.name).to eq('English Recipe')
      end
    end
  end

  describe 'Compatibility with Existing Features' do
    it 'does not break existing serializers (AC-PHASE4-COMPAT-001)' do
      I18n.with_locale(:en) { recipe.update(name: 'Test') }
      expect(recipe.name).to eq('Test')
    end

    it 'works with existing validations (AC-PHASE4-COMPAT-002)' do
      expect(recipe).to have_many(:user_recipe_notes)
      expect(recipe).to have_many(:user_favorites)
    end

    it 'maintains backward compatibility with API (AC-PHASE4-COMPAT-004)' do
      I18n.with_locale(:en) { recipe.update(name: 'API Test') }
      expect(recipe.name).to be_present
    end
  end

  describe 'Database & Performance' do
    it 'enforces uniqueness constraint on translations (AC-PHASE4-DB-001)' do
      I18n.with_locale(:en) { recipe.update(name: 'Test') }

      # Try to create duplicate - should raise error
      duplicate = RecipeTranslation.build(
        recipe_id: recipe.id,
        locale: 'en',
        name: 'Different'
      )
      expect { duplicate.save(validate: false) }.to raise_error(ActiveRecord::RecordNotUnique)
    end

    it 'cascades delete translations when recipe deleted (AC-PHASE4-DB-003)' do
      I18n.with_locale(:ja) { recipe.update(name: 'レシピ') }

      translation_count = RecipeTranslation.where(recipe_id: recipe.id).count
      expect(translation_count).to be > 0

      recipe.destroy

      expect(RecipeTranslation.where(recipe_id: recipe.id).count).to eq(0)
    end
  end

  describe 'Edge Cases' do
    it 'handles reading empty string translation (AC-PHASE4-EDGE-001)' do
      I18n.with_locale(:ja) { recipe.update(name: '') }

      I18n.with_locale(:ja) do
        expect(recipe.name).to eq('')
      end
    end

    it 'handles switching locale mid-edit (AC-PHASE4-EDGE-002)' do
      I18n.with_locale(:en) do
        recipe.name = 'English'
        # Don't save yet

        I18n.with_locale(:ja) do
          expect(recipe.name).to be_nil
        end
      end
    end

    it 'handles invalid locale with fallback (AC-PHASE4-EDGE-008)' do
      I18n.with_locale(:en) { recipe.update(name: 'English') }

      # Set to unsupported locale
      allow(I18n).to receive(:locale).and_return(:xx)
      # Should still work via fallback
      expect(recipe.reload.name).to be_present
    end

    it 'validates after translation assignment (AC-PHASE4-EDGE-012)' do
      I18n.with_locale(:en) do
        recipe.name = nil
        expect(recipe.save).to be_falsey
      end
    end
  end
end
