require 'rails_helper'

describe 'DataReference Translations (AC-PHASE4-MODEL-006)', type: :model do
  let(:data_reference) do
    create(:data_reference,
           reference_type: 'dietary_tag',
           key: 'vegetarian',
           display_name: 'Vegetarian')
  end

  describe 'Translation Declaration' do
    it 'translates :display_name field (AC-PHASE4-MODEL-006)' do
      expect(data_reference).to respond_to(:display_name=)
      expect(data_reference).to respond_to(:display_name)
    end

    it 'uses Table backend for translations' do
      I18n.with_locale(:ja) do
        data_reference.update(display_name: 'ベジタリアン')
      end

      translation = DataReferenceTranslation.find_by(
        data_reference_id: data_reference.id,
        locale: 'ja'
      )
      expect(translation).to be_present
      expect(translation.display_name).to eq('ベジタリアン')
    end

    it 'is scoped to data_reference and locale' do
      other_ref = create(:data_reference,
                        reference_type: 'cuisine',
                        key: 'italian',
                        display_name: 'Italian')

      I18n.with_locale(:ja) do
        data_reference.update(display_name: 'ベジタリアン')
        other_ref.update(display_name: 'イタリアン')
      end

      ja_trans = DataReferenceTranslation.find_by(
        data_reference_id: data_reference.id,
        locale: 'ja'
      )
      expect(ja_trans.display_name).to eq('ベジタリアン')

      other_trans = DataReferenceTranslation.find_by(
        data_reference_id: other_ref.id,
        locale: 'ja'
      )
      expect(other_trans.display_name).to eq('イタリアン')
    end
  end

  describe 'Reading and Writing' do
    it 'reads translation in current locale' do
      I18n.with_locale(:ja) do
        data_reference.update(display_name: 'ベジタリアン')
      end

      I18n.with_locale(:ja) do
        expect(data_reference.display_name).to eq('ベジタリアン')
      end
    end

    it 'writes translation to current locale' do
      I18n.with_locale(:en) do
        data_reference.update(display_name: 'Vegan')
      end

      translation = DataReferenceTranslation.find_by(
        data_reference_id: data_reference.id,
        locale: 'en'
      )
      expect(translation.display_name).to eq('Vegan')
    end

    it 'falls back to fallback locale when missing' do
      I18n.with_locale(:en) do
        data_reference.update(display_name: 'English Tag')
      end

      I18n.with_locale(:ja) do
        expect(data_reference.display_name).to eq('English Tag')
      end
    end

    it 'handles updating translation' do
      I18n.with_locale(:ja) do
        data_reference.update(display_name: 'ベジタリアン')
      end

      I18n.with_locale(:ja) do
        data_reference.update(display_name: 'ベジタリアン改')
      end

      translation = DataReferenceTranslation.find_by(
        data_reference_id: data_reference.id,
        locale: 'ja'
      )
      expect(translation.display_name).to eq('ベジタリアン改')
    end
  end

  describe 'Cascade Delete' do
    it 'deletes translations when data_reference deleted' do
      I18n.with_locale(:ja) do
        data_reference.update(display_name: 'ベジタリアン')
      end

      trans_count = DataReferenceTranslation.where(
        data_reference_id: data_reference.id
      ).count
      expect(trans_count).to be > 0

      data_reference.destroy

      expect(DataReferenceTranslation.where(
        data_reference_id: data_reference.id
      ).count).to eq(0)
    end
  end

  describe 'Querying' do
    before do
      create(:data_reference,
             reference_type: 'dietary_tag',
             key: 'vegan',
             display_name: 'Vegan')
      create(:data_reference,
             reference_type: 'cuisine',
             key: 'italian',
             display_name: 'Italian')
    end

    it 'queries by translated field' do
      I18n.with_locale(:en) do
        results = DataReference.i18n.where(display_name: 'Vegan')
        expect(results).to be_a(ActiveRecord::Relation)
      end
    end

    it 'queries with reference_type scope' do
      I18n.with_locale(:en) do
        results = DataReference.dietary_tags.i18n.where(display_name: 'Vegetarian')
        expect(results).to be_a(ActiveRecord::Relation)
      end
    end
  end

  describe 'Uniqueness Validation' do
    it 'enforces uniqueness in same locale' do
      create(:data_reference,
             reference_type: 'dietary_tag',
             key: 'unique',
             display_name: 'Unique')

      duplicate = build(:data_reference,
                       reference_type: 'dietary_tag',
                       key: 'unique_2',
                       display_name: 'Unique')
      expect(duplicate).not_to be_valid
    end

    it 'allows same value in different locales' do
      I18n.with_locale(:en) do
        data_reference.update(display_name: 'Shared')
      end

      I18n.with_locale(:ja) do
        data_reference.display_name = 'Shared'
        expect(data_reference).to be_valid
      end
    end

    it 'allows same display_name for different reference_type' do
      other_ref = create(:data_reference,
                        reference_type: 'cuisine',
                        key: 'italian',
                        display_name: 'Vegetarian')

      # Same display_name, different reference_type
      expect(other_ref).to be_valid
    end
  end

  describe 'Null and Empty Values' do
    it 'handles nil translation' do
      I18n.with_locale(:ja) do
        data_reference.update(display_name: nil)
      end

      I18n.with_locale(:ja) do
        expect(data_reference.display_name).to be_nil
      end
    end

    it 'converts empty strings to nil (Mobility presence plugin)' do
      I18n.with_locale(:ja) do
        data_reference.update(display_name: '')
      end

      I18n.with_locale(:ja) do
        # Mobility presence plugin converts empty strings to nil
        expect(data_reference.display_name).to be_nil
      end
    end
  end

  describe 'Scope Integration' do
    it 'works with dietary_tags scope' do
      I18n.with_locale(:ja) do
        data_reference.update(display_name: 'ベジタリアン')
      end

      results = DataReference.dietary_tags
      expect(results).to include(data_reference)
    end

    it 'works with active scope' do
      I18n.with_locale(:en) do
        data_reference.update(active: true)
      end

      results = DataReference.active
      expect(results).to include(data_reference)
    end

    it 'combines scopes with translation' do
      I18n.with_locale(:ja) do
        data_reference.update(display_name: 'ベジタリアン')
      end

      I18n.with_locale(:ja) do
        results = DataReference.dietary_tags.i18n.where(display_name: 'ベジタリアン')
        expect(results).to include(data_reference)
      end
    end
  end

  describe 'Association with Recipes' do
    let(:recipe) { create(:recipe) }

    it 'maintains associations when translated' do
      I18n.with_locale(:ja) do
        data_reference.update(display_name: 'ベジタリアン')
      end

      recipe.dietary_tags << data_reference

      expect(recipe.dietary_tags).to include(data_reference)

      I18n.with_locale(:ja) do
        expect(recipe.dietary_tags.first.display_name).to eq('ベジタリアン')
      end
    end
  end
end
