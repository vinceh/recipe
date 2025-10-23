require 'rails_helper'

RSpec.describe AiPrompt, type: :model do
  describe 'validations' do
    describe 'prompt_key presence' do
      it 'requires prompt_key to be present (AC-MODEL-PROMPT-001)' do
        prompt = build(:ai_prompt, prompt_key: nil)
        expect(prompt).not_to be_valid
        expect(prompt.errors[:prompt_key]).to include("can't be blank")
      end
    end

    describe 'prompt_text presence' do
      it 'requires prompt_text to be present (AC-MODEL-PROMPT-002)' do
        prompt = build(:ai_prompt, prompt_text: nil)
        expect(prompt).not_to be_valid
        expect(prompt.errors[:prompt_text]).to include("can't be blank")
      end
    end

    describe 'prompt_key uniqueness' do
      it 'enforces prompt_key uniqueness (AC-MODEL-PROMPT-003)' do
        create(:ai_prompt, prompt_key: 'recipe_parse_text_system')
        duplicate = build(:ai_prompt, prompt_key: 'recipe_parse_text_system')
        expect(duplicate).not_to be_valid
        expect(duplicate.errors[:prompt_key]).to include('has already been taken')
      end
    end
  end
end
