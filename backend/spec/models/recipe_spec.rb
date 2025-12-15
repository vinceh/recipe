require 'rails_helper'

describe Recipe do
  describe 'description field with Mobility' do
    let(:cuisine) do
      DataReference.find_or_create_by!(reference_type: 'cuisine', key: 'test') { |r| r.display_name = 'Test' }
    end

    let(:recipe) do
      recipe = Recipe.new(
        name: "Test Recipe",
        description: "A delicious recipe",
        source_language: "en",
        servings_original: 2,
        prep_minutes: 10,
        cook_minutes: 20,
        total_minutes: 30
      )
      recipe.recipe_steps.build(step_number: 1, instruction_original: "Test step")
      ig = recipe.ingredient_groups.build(name: "Ingredients", position: 1)
      ingredient = Ingredient.find_or_create_by!(canonical_name: "test ingredient") { |i| i.category = "vegetable" }
      unit = Unit.find_or_create_by!(canonical_name: "cup") { |u| u.category = "unit_volume" }
      ig.recipe_ingredients.build(ingredient_id: ingredient.id, ingredient_name: "test ingredient", amount: 1, unit: unit, position: 1)
      recipe.recipe_cuisines.build(data_reference: cuisine)
      recipe.card_image.attach(
        io: File.open(Rails.root.join('spec/fixtures/files/test_image.png')),
        filename: 'test_card_image.png',
        content_type: 'image/png'
      )
      recipe.detail_image.attach(
        io: File.open(Rails.root.join('spec/fixtures/files/test_image.png')),
        filename: 'test_detail_image.png',
        content_type: 'image/png'
      )
      recipe
    end

    it 'is translatable via Mobility' do
      expect(Recipe.mobility_attributes.map(&:to_s)).to include('description')
    end

    it 'stores description in recipe_translations table' do
      recipe.save!

      translation = RecipeTranslation.find_by(recipe_id: recipe.id, locale: 'en')
      expect(translation.description).to eq("A delicious recipe")
    end

    it 'retrieves description for current locale' do
      I18n.with_locale(:en) do
        recipe.save!
      end

      I18n.with_locale(:en) do
        recipe.reload
        expect(recipe.description).to eq("A delicious recipe")
      end
    end


    it 'handles long descriptions (TEXT type)' do
      long_description = "Lorem ipsum dolor sit amet, " * 100 # Over 1000 characters
      recipe.description = long_description
      recipe.save!

      recipe.reload
      expect(recipe.description).to eq(long_description)
    end

    it 'requires description field to be NOT NULL in database' do
      # Verify the column constraint
      column_info = RecipeTranslation.columns.find { |c| c.name == 'description' }
      expect(column_info.null).to be false
    end
  end

  describe 'difficulty_level enum' do
    let(:cuisine) do
      DataReference.find_or_create_by!(reference_type: 'cuisine', key: 'test') { |r| r.display_name = 'Test' }
    end

    let(:recipe) do
      recipe = Recipe.new(
        name: "Test Recipe",
        description: "A delicious recipe",
        source_language: "en",
        servings_original: 2,
        prep_minutes: 10,
        cook_minutes: 20,
        total_minutes: 30
      )
      recipe.recipe_steps.build(step_number: 1, instruction_original: "Test step")
      ig = recipe.ingredient_groups.build(name: "Ingredients", position: 1)
      ingredient = Ingredient.find_or_create_by!(canonical_name: "test ingredient") { |i| i.category = "vegetable" }
      unit = Unit.find_or_create_by!(canonical_name: "cup") { |u| u.category = "unit_volume" }
      ig.recipe_ingredients.build(ingredient_id: ingredient.id, ingredient_name: "test ingredient", amount: 1, unit: unit, position: 1)
      recipe.recipe_cuisines.build(data_reference: cuisine)
      recipe.card_image.attach(
        io: File.open(Rails.root.join('spec/fixtures/files/test_image.png')),
        filename: 'test_card_image.png',
        content_type: 'image/png'
      )
      recipe.detail_image.attach(
        io: File.open(Rails.root.join('spec/fixtures/files/test_image.png')),
        filename: 'test_detail_image.png',
        content_type: 'image/png'
      )
      recipe
    end

    it 'supports easy, medium, hard values' do
      expect(Recipe.difficulty_levels.keys).to match_array(%w[easy medium hard])
    end

    it 'maps easy to 0, medium to 1, hard to 2' do
      expect(Recipe.difficulty_levels['easy']).to eq(0)
      expect(Recipe.difficulty_levels['medium']).to eq(1)
      expect(Recipe.difficulty_levels['hard']).to eq(2)
    end

    it 'accepts valid difficulty levels' do
      %w[easy medium hard].each do |level|
        recipe.difficulty_level = level
        expect(recipe).to be_valid
      end
    end

    it 'rejects invalid difficulty levels' do
      expect { recipe.difficulty_level = 'impossible' }.to raise_error(ArgumentError)
    end

    it 'requires difficulty_level to be present' do
      recipe.difficulty_level = nil
      expect(recipe).not_to be_valid
      expect(recipe.errors[:difficulty_level]).to include("can't be blank")
    end

    it 'provides query methods for each difficulty level' do
      recipe.difficulty_level = 'easy'
      recipe.save!

      recipe.reload
      expect(recipe.easy?).to be true
      expect(recipe.medium?).to be false
      expect(recipe.hard?).to be false
    end

    it 'allows querying recipes by difficulty_level scope' do
      recipe.difficulty_level = 'hard'
      recipe.save!

      expect(Recipe.hard).to include(recipe)
      expect(Recipe.easy).not_to include(recipe)
    end
  end

  describe 'image attachment' do
    it 'has card_image and detail_image attached after creation' do
      recipe = create(:recipe)
      expect(recipe.card_image).to be_attached
      expect(recipe.detail_image).to be_attached
    end

    it 'requires both images to be present' do
      recipe = create(:recipe)
      recipe.card_image.purge
      recipe.detail_image.purge
      expect(recipe).not_to be_valid
      expect(recipe.errors[:card_image]).to include('must be attached')
      expect(recipe.errors[:detail_image]).to include('must be attached')
    end

    it 'accepts valid image formats' do
      %w[image/png image/jpg image/jpeg image/gif image/webp].each do |content_type|
        recipe = create(:recipe)
        recipe.card_image.purge
        recipe.detail_image.purge
        recipe.card_image.attach(
          io: StringIO.new('fake'),
          filename: 'test_card.png',
          content_type: content_type
        )
        recipe.detail_image.attach(
          io: StringIO.new('fake'),
          filename: 'test_detail.png',
          content_type: content_type
        )
        expect(recipe).to be_valid
      end
    end

    skip 'rejects invalid image formats - requires image validator implementation' do
      recipe = create(:recipe)
      recipe.card_image.purge
      recipe.card_image.attach(
        io: StringIO.new('fake'),
        filename: 'test.pdf',
        content_type: 'application/pdf'
      )
      expect(recipe).not_to be_valid
      expect(recipe.errors[:card_image]).not_to be_empty
    end

    skip 'enforces maximum file size of 10MB - requires image size validator implementation' do
      recipe = create(:recipe)
      recipe.card_image.purge

      large_file = StringIO.new('x' * (11 * 1024 * 1024))
      allow(large_file).to receive(:size).and_return(11 * 1024 * 1024)

      recipe.card_image.attach(
        io: large_file,
        filename: 'large.png',
        content_type: 'image/png'
      )
      expect(recipe).not_to be_valid
      expect(recipe.errors[:card_image]).not_to be_empty
    end
  end

  describe 'tags attribute' do
    it 'defaults to empty array' do
      recipe = create(:recipe)
      expect(recipe.tags).to eq([])
    end

    it 'can store multiple string tags' do
      recipe = create(:recipe)
      recipe.update!(tags: ['quick', 'easy', 'weeknight'])
      recipe.reload
      expect(recipe.tags).to eq(['quick', 'easy', 'weeknight'])
    end

    it 'can be queried with ANY operator' do
      recipe = create(:recipe)
      recipe.update!(tags: ['quick', 'dinner'])

      results = Recipe.where("? = ANY(tags)", 'quick')
      expect(results).to include(recipe)

      results = Recipe.where("? = ANY(tags)", 'nonexistent')
      expect(results).not_to include(recipe)
    end

    it 'can be cleared by setting to empty array' do
      recipe = create(:recipe)
      recipe.update!(tags: ['something'])
      recipe.update!(tags: [])
      recipe.reload
      expect(recipe.tags).to eq([])
    end
  end
end
