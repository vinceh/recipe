require 'rails_helper'

RSpec.describe UnitConverter do
  describe '.convert' do
    context 'direct conversions' do
      it 'converts cups to tbsp' do
        expect(UnitConverter.convert(1, 'cup', 'tbsp')).to eq(16)
      end

      it 'converts cups to tsp' do
        expect(UnitConverter.convert(1, 'cup', 'tsp')).to eq(48)
      end

      it 'converts tbsp to tsp' do
        expect(UnitConverter.convert(1, 'tbsp', 'tsp')).to eq(3)
      end

      it 'converts kg to g' do
        expect(UnitConverter.convert(1, 'kg', 'g')).to eq(1000)
      end

      it 'converts lb to oz' do
        expect(UnitConverter.convert(1, 'lb', 'oz')).to eq(16)
      end

      it 'converts lb to g' do
        expect(UnitConverter.convert(1, 'lb', 'g')).to eq(453.592)
      end
    end

    context 'reverse conversions' do
      it 'converts tbsp to cup' do
        expect(UnitConverter.convert(16, 'tbsp', 'cup')).to eq(1)
      end

      it 'converts tsp to tbsp' do
        expect(UnitConverter.convert(3, 'tsp', 'tbsp')).to eq(1)
      end

      it 'converts g to kg' do
        expect(UnitConverter.convert(1000, 'g', 'kg')).to eq(1)
      end

      it 'converts oz to lb' do
        expect(UnitConverter.convert(16, 'oz', 'lb')).to eq(1)
      end
    end

    context 'multi-hop conversions via common unit' do
      it 'converts tbsp to cup via ml' do
        result = UnitConverter.convert(1, 'tbsp', 'cup')
        expect(result).to be_within(0.01).of(0.0625)
      end

      it 'converts tsp to cup via ml' do
        result = UnitConverter.convert(1, 'tsp', 'cup')
        expect(result).to be_within(0.01).of(0.0208)
      end
    end

    context 'same unit' do
      it 'returns same amount when units match' do
        expect(UnitConverter.convert(5, 'cup', 'cup')).to eq(5)
        expect(UnitConverter.convert(10, 'g', 'g')).to eq(10)
      end
    end

    context 'fractional amounts' do
      it 'converts 0.5 cups to tbsp' do
        expect(UnitConverter.convert(0.5, 'cup', 'tbsp')).to eq(8)
      end

      it 'converts 2.5 tbsp to tsp' do
        expect(UnitConverter.convert(2.5, 'tbsp', 'tsp')).to eq(7.5)
      end
    end
  end

  describe '.to_grams' do
    it 'converts oz to grams' do
      result = UnitConverter.to_grams(1, 'oz')
      expect(result).to be_within(0.01).of(28.35)
    end

    it 'converts lb to grams' do
      result = UnitConverter.to_grams(1, 'lb')
      expect(result).to be_within(0.01).of(453.59)
    end

    it 'converts kg to grams' do
      expect(UnitConverter.to_grams(1, 'kg')).to eq(1000)
    end

    it 'returns same value for grams' do
      expect(UnitConverter.to_grams(100, 'g')).to eq(100)
    end
  end
end
