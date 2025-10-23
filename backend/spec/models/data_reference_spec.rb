require 'rails_helper'

RSpec.describe DataReference, type: :model do
  describe 'validations' do
    describe 'key presence' do
      it 'requires key to be present (AC-MODEL-DATAREF-001)' do
        ref = build(:data_reference, key: nil)
        expect(ref).not_to be_valid
        expect(ref.errors[:key]).to include("can't be blank")
      end
    end

    describe 'reference_type presence' do
      it 'requires reference_type to be present (AC-MODEL-DATAREF-002)' do
        ref = build(:data_reference, reference_type: nil)
        expect(ref).not_to be_valid
        expect(ref.errors[:reference_type]).to include("can't be blank")
      end
    end

    describe 'display_name presence' do
      it 'requires display_name to be present (AC-MODEL-DATAREF-003)' do
        ref = build(:data_reference, display_name: nil)
        expect(ref).not_to be_valid
        expect(ref.errors[:display_name]).to include("can't be blank")
      end
    end

    describe 'key uniqueness scoped to reference_type' do
      it 'enforces uniqueness within reference_type (AC-MODEL-DATAREF-004)' do
        create(:data_reference, key: 'vegetarian', reference_type: 'dietary_tag')
        duplicate = build(:data_reference, key: 'vegetarian', reference_type: 'dietary_tag')
        expect(duplicate).not_to be_valid
        expect(duplicate.errors[:key]).to include('has already been taken')
      end

      it 'allows same key with different reference_type (AC-MODEL-DATAREF-005)' do
        create(:data_reference, key: 'vegetarian', reference_type: 'dietary_tag')
        ref = build(:data_reference, key: 'vegetarian', reference_type: 'recipe_type')
        expect(ref).to be_valid
      end
    end

    describe 'reference_type enum' do
      it 'accepts valid reference_type values (AC-MODEL-DATAREF-006)' do
        %w[dietary_tag dish_type cuisine recipe_type].each do |type|
          ref = build(:data_reference, reference_type: type)
          expect(ref).to be_valid, "Expected reference_type '#{type}' to be valid"
        end
      end

      it 'rejects invalid reference_type values (AC-MODEL-DATAREF-007)' do
        ref = build(:data_reference, reference_type: 'invalid_type')
        expect(ref).not_to be_valid
      end
    end
  end

  describe 'associations' do
    it 'has many recipes as dietary_tag' do
      ref = create(:data_reference, reference_type: 'dietary_tag')
      expect(ref).to respond_to(:recipes_as_dietary_tag)
    end

    it 'has many recipes as dish_type' do
      ref = create(:data_reference, reference_type: 'dish_type')
      expect(ref).to respond_to(:recipes_as_dish_type)
    end

    it 'has many recipes as cuisine' do
      ref = create(:data_reference, reference_type: 'cuisine')
      expect(ref).to respond_to(:recipes_as_cuisine)
    end

    it 'has many recipes as recipe_type' do
      ref = create(:data_reference, reference_type: 'recipe_type')
      expect(ref).to respond_to(:recipes_as_recipe_type)
    end
  end
end
