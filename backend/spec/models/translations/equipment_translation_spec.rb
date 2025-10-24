require 'rails_helper'

describe 'Equipment Translations (AC-PHASE4-MODEL-004)', type: :model do
  let(:equipment) { create(:equipment, canonical_name: 'Baking Pan') }

  describe 'Translation Declaration' do
    it 'translates :canonical_name field (AC-PHASE4-MODEL-004)' do
      expect(equipment).to respond_to(:canonical_name=)
      expect(equipment).to respond_to(:canonical_name)
    end

    it 'uses Table backend for translations' do
      I18n.with_locale(:ja) do
        equipment.update(canonical_name: 'ベーキングパン')
      end

      translation = EquipmentTranslation.find_by(
        equipment_id: equipment.id,
        locale: 'ja'
      )
      expect(translation).to be_present
      expect(translation.canonical_name).to eq('ベーキングパン')
    end
  end

  describe 'Reading and Writing' do
    it 'reads translation in current locale' do
      I18n.with_locale(:ja) do
        equipment.update(canonical_name: 'ベーキングパン')
      end

      I18n.with_locale(:ja) do
        expect(equipment.canonical_name).to eq('ベーキングパン')
      end
    end

    it 'writes translation to current locale' do
      I18n.with_locale(:en) do
        equipment.update(canonical_name: 'Updated Pan')
      end

      translation = EquipmentTranslation.find_by(
        equipment_id: equipment.id,
        locale: 'en'
      )
      expect(translation.canonical_name).to eq('Updated Pan')
    end

    it 'falls back to fallback locale when missing' do
      I18n.with_locale(:en) do
        equipment.update(canonical_name: 'English Pan')
      end

      I18n.with_locale(:ja) do
        expect(equipment.canonical_name).to eq('English Pan')
      end
    end

    it 'handles updating translation' do
      I18n.with_locale(:ja) do
        equipment.update(canonical_name: 'ベーキングパン')
      end

      I18n.with_locale(:ja) do
        equipment.update(canonical_name: 'オーブンパン')
      end

      translation = EquipmentTranslation.find_by(
        equipment_id: equipment.id,
        locale: 'ja'
      )
      expect(translation.canonical_name).to eq('オーブンパン')
    end
  end

  describe 'Uniqueness Validation' do
    it 'enforces uniqueness on canonical_name in same locale' do
      create(:equipment, canonical_name: 'Unique Pan')

      duplicate = build(:equipment, canonical_name: 'Unique Pan')
      expect(duplicate).not_to be_valid
    end

    it 'allows same name in different locales' do
      I18n.with_locale(:en) do
        equipment.update(canonical_name: 'Shared Name')
      end

      I18n.with_locale(:ja) do
        equipment.canonical_name = 'Shared Name'
        expect(equipment).to be_valid
      end
    end
  end

  describe 'Cascade Delete' do
    it 'deletes translations when equipment deleted' do
      I18n.with_locale(:ja) do
        equipment.update(canonical_name: 'ベーキングパン')
      end

      trans_count = EquipmentTranslation.where(
        equipment_id: equipment.id
      ).count
      expect(trans_count).to be > 0

      equipment.destroy

      expect(EquipmentTranslation.where(
        equipment_id: equipment.id
      ).count).to eq(0)
    end
  end

  describe 'Querying' do
    before do
      create(:equipment, canonical_name: 'Knife')
      create(:equipment, canonical_name: 'Spoon')
    end

    it 'queries by translated field' do
      I18n.with_locale(:en) do
        results = Equipment.i18n.where(canonical_name: 'Knife')
        expect(results).to be_a(ActiveRecord::Relation)
      end
    end
  end

  describe 'Null and Empty Values' do
    it 'handles nil translation' do
      I18n.with_locale(:ja) do
        equipment.update(canonical_name: nil)
      end

      I18n.with_locale(:ja) do
        expect(equipment.canonical_name).to be_nil
      end
    end

    it 'handles empty string' do
      I18n.with_locale(:ja) do
        equipment.update(canonical_name: '')
      end

      I18n.with_locale(:ja) do
        expect(equipment.canonical_name).to eq('')
      end
    end
  end
end
