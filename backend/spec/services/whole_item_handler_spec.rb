require 'rails_helper'

RSpec.describe WholeItemHandler do
  describe '.scale_whole_item' do
    context 'with whole items' do
      it 'rounds eggs to nearest 0.5' do
        result = WholeItemHandler.scale_whole_item('eggs', 2, 1.5, 'cooking')
        expect(result[:amount]).to eq(3.0)
        expect(result[:unit]).to eq('whole')
      end

      it 'rounds 2.3 eggs to 2.5' do
        result = WholeItemHandler.scale_whole_item('eggs', 2, 1.15, 'cooking')
        expect(result[:amount]).to eq(2.5)
        expect(result[:unit]).to eq('whole')
      end

      it 'rounds 2.7 eggs to 2.5' do
        result = WholeItemHandler.scale_whole_item('eggs', 2, 1.35, 'cooking')
        expect(result[:amount]).to eq(2.5) # (2.7 * 2).round / 2.0 = 5/2 = 2.5
        expect(result[:unit]).to eq('whole')
      end

      it 'handles onions' do
        result = WholeItemHandler.scale_whole_item('onions', 1, 1.4, 'cooking')
        expect(result[:amount]).to eq(1.5)
        expect(result[:unit]).to eq('whole')
      end

      it 'handles garlic cloves' do
        result = WholeItemHandler.scale_whole_item('cloves', 3, 0.5, 'cooking')
        expect(result[:amount]).to eq(1.5)
        expect(result[:unit]).to eq('whole')
      end
    end

    context 'baking context with fractional eggs' do
      it 'converts fractional eggs to grams for baking' do
        result = WholeItemHandler.scale_whole_item('eggs', 2, 0.4, 'baking')
        expect(result[:amount]).to eq(40.0) # 0.8 eggs * 50g
        expect(result[:unit]).to eq('g')
        expect(result[:note]).to eq('beaten egg')
      end

      it 'converts 0.5 eggs to grams for baking' do
        result = WholeItemHandler.scale_whole_item('eggs', 1, 0.5, 'baking')
        expect(result[:amount]).to eq(25.0) # 0.5 eggs * 50g
        expect(result[:unit]).to eq('g')
        expect(result[:note]).to eq('beaten egg')
      end
    end

    context 'very small amounts' do
      it 'omits ingredients when scaled below 0.3' do
        result = WholeItemHandler.scale_whole_item('eggs', 2, 0.1, 'cooking')
        expect(result[:amount]).to eq(0)
        expect(result[:unit]).to eq('whole')
        expect(result[:note]).to eq('omit')
      end

      it 'omits onions when scaled to 0.25' do
        result = WholeItemHandler.scale_whole_item('onions', 1, 0.25, 'cooking')
        expect(result[:amount]).to eq(0)
        expect(result[:unit]).to eq('whole')
        expect(result[:note]).to eq('omit')
      end
    end

    context 'non-whole items' do
      it 'scales normally for non-whole items' do
        result = WholeItemHandler.scale_whole_item('flour', 100, 2, 'cooking')
        expect(result).to eq(200)
      end

      it 'handles fractional scaling for regular ingredients' do
        result = WholeItemHandler.scale_whole_item('sugar', 50, 1.5, 'cooking')
        expect(result).to eq(75.0)
      end
    end

    context 'edge cases' do
      it 'handles scaling factor of 1' do
        result = WholeItemHandler.scale_whole_item('eggs', 3, 1, 'cooking')
        expect(result[:amount]).to eq(3.0)
        expect(result[:unit]).to eq('whole')
      end

      it 'handles large scaling factors' do
        result = WholeItemHandler.scale_whole_item('eggs', 2, 5, 'cooking')
        expect(result[:amount]).to eq(10.0)
        expect(result[:unit]).to eq('whole')
      end
    end
  end

  describe '.is_whole_item?' do
    it 'identifies eggs as whole item' do
      expect(WholeItemHandler.is_whole_item?('eggs')).to be true
      expect(WholeItemHandler.is_whole_item?('egg')).to be true
    end

    it 'identifies onions as whole item' do
      expect(WholeItemHandler.is_whole_item?('onions')).to be true
      expect(WholeItemHandler.is_whole_item?('onion')).to be true
    end

    it 'identifies cloves as whole item' do
      expect(WholeItemHandler.is_whole_item?('cloves')).to be true
      expect(WholeItemHandler.is_whole_item?('clove')).to be true
    end

    it 'handles case insensitivity' do
      expect(WholeItemHandler.is_whole_item?('EGGS')).to be true
      expect(WholeItemHandler.is_whole_item?('Onion')).to be true
    end

    it 'identifies non-whole items correctly' do
      expect(WholeItemHandler.is_whole_item?('flour')).to be false
      expect(WholeItemHandler.is_whole_item?('sugar')).to be false
      expect(WholeItemHandler.is_whole_item?('milk')).to be false
    end
  end
end
