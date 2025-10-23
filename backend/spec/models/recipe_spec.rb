require 'rails_helper'

RSpec.describe Recipe, type: :model do
  def create_dietary_tag(key, display_name = nil)
    DataReference.find_or_create_by(reference_type: 'dietary_tag', key: key) do |r|
      r.display_name = display_name || key.titleize
    end
  end

  def create_dish_type(key, display_name = nil)
    DataReference.find_or_create_by(reference_type: 'dish_type', key: key) do |r|
      r.display_name = display_name || key.titleize
    end
  end

  def create_cuisine(key, display_name = nil)
    DataReference.find_or_create_by(reference_type: 'cuisine', key: key) do |r|
      r.display_name = display_name || key.titleize
    end
  end

  def create_recipe_type(key, display_name = nil)
    DataReference.find_or_create_by(reference_type: 'recipe_type', key: key) do |r|
      r.display_name = display_name || key.titleize
    end
  end

  def create_equipment(name)
    Equipment.find_or_create_by!(canonical_name: name)
  end

  def create_ingredient(name, category = nil)
    Ingredient.find_or_create_by!(canonical_name: name) do |i|
      i.category = category || 'other'
    end
  end
  describe 'validations' do
    it 'requires name to be present' do
      recipe = build(:recipe, name: nil)
      expect(recipe).not_to be_valid
      expect(recipe.errors[:name]).to be_present
    end

    it 'requires source_language to be present' do
      recipe = build(:recipe, source_language: nil)
      expect(recipe).not_to be_valid
      expect(recipe.errors[:source_language]).to be_present
    end

    it 'validates source_language is in allowed languages' do
      recipe = build(:recipe, source_language: 'invalid')
      expect(recipe).not_to be_valid
      expect(recipe.errors[:source_language]).to be_present
    end

    it 'accepts valid source_language values' do
      %w[en ja ko zh-tw zh-cn es fr].each do |lang|
        recipe = build(:recipe, source_language: lang)
        expect(recipe).to be_valid
      end
    end

    it 'validates precision_reason is in allowed values when present' do
      recipe = build(:recipe, precision_reason: 'invalid')
      expect(recipe).not_to be_valid
      expect(recipe.errors[:precision_reason]).to be_present
    end

    it 'accepts valid precision_reason values' do
      %w[baking confectionery fermentation molecular].each do |reason|
        recipe = build(:recipe, precision_reason: reason)
        expect(recipe).to be_valid
      end
    end

    it 'allows precision_reason to be nil' do
      recipe = build(:recipe, precision_reason: nil)
      expect(recipe).to be_valid
    end
  end

  describe 'associations' do
    it 'has many ingredient groups' do
      recipe = create(:recipe)
      expect(recipe.ingredient_groups).to be_a(ActiveRecord::Associations::CollectionProxy)
    end

    it 'has many recipe ingredients through ingredient groups' do
      recipe = create(:recipe)
      group = recipe.ingredient_groups.create!(name: 'Test', position: 1)
      group.recipe_ingredients.create!(ingredient_name: 'test', position: 1)

      expect(recipe.recipe_ingredients).to be_a(ActiveRecord::Associations::CollectionProxy)
      expect(recipe.recipe_ingredients.count).to eq(1)
    end

    it 'has many recipe steps' do
      recipe = create(:recipe)
      expect(recipe.recipe_steps).to be_a(ActiveRecord::Associations::CollectionProxy)
    end

    it 'has one recipe nutrition' do
      recipe = create(:recipe)
      expect(recipe.respond_to?(:recipe_nutrition)).to be true
    end

    it 'has many recipe equipment' do
      recipe = create(:recipe)
      expect(recipe.recipe_equipment).to be_a(ActiveRecord::Associations::CollectionProxy)
    end

    it 'has many equipment through recipe equipment' do
      recipe = create(:recipe)
      pan = Equipment.find_or_create_by!(canonical_name: 'pan')
      recipe.recipe_equipment.create!(equipment_id: pan.id)

      expect(recipe.equipment).to be_a(ActiveRecord::Associations::CollectionProxy)
      expect(recipe.equipment.count).to eq(1)
    end

    it 'has many dietary tags through recipe dietary tags' do
      recipe = create(:recipe)
      veg = create_dietary_tag('veg', 'Veg')
      recipe.recipe_dietary_tags.create!(data_reference_id: veg.id)

      expect(recipe.dietary_tags).to be_a(ActiveRecord::Associations::CollectionProxy)
      expect(recipe.dietary_tags.count).to eq(1)
    end

    it 'has many dish types through recipe dish types' do
      recipe = create(:recipe)
      main = create_dish_type('main', 'Main')
      recipe.recipe_dish_types.create!(data_reference_id: main.id)

      expect(recipe.dish_types).to be_a(ActiveRecord::Associations::CollectionProxy)
      expect(recipe.dish_types.count).to eq(1)
    end

    it 'has many cuisines through recipe cuisines' do
      recipe = create(:recipe)
      jp = create_cuisine('jp', 'JP')
      recipe.recipe_cuisines.create!(data_reference_id: jp.id)

      expect(recipe.cuisines).to be_a(ActiveRecord::Associations::CollectionProxy)
      expect(recipe.cuisines.count).to eq(1)
    end

    it 'has many recipe types through recipe recipe types' do
      recipe = create(:recipe)
      quick = create_recipe_type('quick', 'Quick')
      recipe.recipe_recipe_types.create!(data_reference_id: quick.id)

      expect(recipe.recipe_types).to be_a(ActiveRecord::Associations::CollectionProxy)
      expect(recipe.recipe_types.count).to eq(1)
    end

    it 'has many recipe aliases' do
      recipe = create(:recipe)
      expect(recipe.recipe_aliases).to be_a(ActiveRecord::Associations::CollectionProxy)
    end

    it 'has many user recipe notes' do
      recipe = create(:recipe)
      expect(recipe.user_recipe_notes).to be_a(ActiveRecord::Associations::CollectionProxy)
    end

    it 'has many user favorites' do
      recipe = create(:recipe)
      expect(recipe.user_favorites).to be_a(ActiveRecord::Associations::CollectionProxy)
    end
  end

  describe 'normalized schema - ingredient groups' do
    let(:recipe) { create(:recipe) }

    it 'can have multiple ingredient groups' do
      group1 = recipe.ingredient_groups.create!(name: 'Main Ingredients', position: 1)
      group2 = recipe.ingredient_groups.create!(name: 'Sauce', position: 2)

      expect(recipe.ingredient_groups.count).to eq(2)
      expect(recipe.ingredient_groups.map(&:name)).to match_array(['Main Ingredients', 'Sauce'])
    end

    it 'maintains position order' do
      recipe.ingredient_groups.create!(name: 'First', position: 1)
      recipe.ingredient_groups.create!(name: 'Third', position: 3)
      recipe.ingredient_groups.create!(name: 'Second', position: 2)

      positions = recipe.ingredient_groups.order(:position).pluck(:name)
      expect(positions).to eq(['First', 'Second', 'Third'])
    end

    it 'cascades delete when recipe is deleted' do
      group = recipe.ingredient_groups.create!(name: 'Test', position: 1)
      group_id = group.id

      recipe.destroy
      expect(IngredientGroup.find_by(id: group_id)).to be_nil
    end
  end

  describe 'normalized schema - recipe ingredients' do
    let(:recipe) { create(:recipe) }
    let(:group) { recipe.ingredient_groups.create!(name: 'Main', position: 1) }

    it 'can have recipe ingredients with full field coverage' do
      ingredient = Ingredient.find_or_create_by!(canonical_name: 'chicken') { |i| i.category = 'protein' }

      recipe_ingredient = group.recipe_ingredients.create!(
        ingredient_id: ingredient.id,
        ingredient_name: 'chicken',
        amount: BigDecimal('300'),
        unit: 'g',
        preparation_notes: 'cut into pieces',
        optional: false,
        position: 1
      )

      expect(recipe_ingredient.ingredient_id).to eq(ingredient.id)
      expect(recipe_ingredient.ingredient_name).to eq('chicken')
      expect(recipe_ingredient.amount).to eq(BigDecimal('300'))
      expect(recipe_ingredient.unit).to eq('g')
      expect(recipe_ingredient.preparation_notes).to eq('cut into pieces')
      expect(recipe_ingredient.optional).to be false
    end

    it 'can have recipe ingredients without ingredient reference' do
      recipe_ingredient = group.recipe_ingredients.create!(
        ingredient_name: 'dashi stock',
        amount: 200,
        unit: 'ml',
        position: 1
      )

      expect(recipe_ingredient.ingredient_id).to be_nil
      expect(recipe_ingredient.ingredient_name).to eq('dashi stock')
    end

    it 'supports optional ingredients' do
      recipe_ingredient = group.recipe_ingredients.create!(
        ingredient_name: 'garnish',
        optional: true,
        position: 1
      )

      expect(recipe_ingredient.optional).to be true
    end

    it 'cascades delete when ingredient group is deleted' do
      recipe_ingredient = group.recipe_ingredients.create!(
        ingredient_name: 'test',
        position: 1
      )
      recipe_ingredient_id = recipe_ingredient.id

      group.destroy
      expect(RecipeIngredient.find_by(id: recipe_ingredient_id)).to be_nil
    end
  end

  describe 'normalized schema - recipe steps' do
    let(:recipe) { create(:recipe) }

    it 'can have multiple recipe steps with timing' do
      step1 = recipe.recipe_steps.create!(step_number: 1, timing_minutes: 5)
      step2 = recipe.recipe_steps.create!(step_number: 2, timing_minutes: 10)
      step3 = recipe.recipe_steps.create!(step_number: 3, timing_minutes: nil)

      expect(recipe.recipe_steps.count).to eq(3)
      expect(step1.timing_minutes).to eq(5)
      expect(step2.timing_minutes).to eq(10)
      expect(step3.timing_minutes).to be_nil
    end

    it 'maintains step number order' do
      recipe.recipe_steps.create!(step_number: 1, timing_minutes: 5)
      recipe.recipe_steps.create!(step_number: 3, timing_minutes: 10)
      recipe.recipe_steps.create!(step_number: 2, timing_minutes: 7)

      step_numbers = recipe.recipe_steps.pluck(:step_number)
      expect(step_numbers).to match_array([1, 2, 3])
    end

    it 'cascades delete when recipe is deleted' do
      step = recipe.recipe_steps.create!(step_number: 1, timing_minutes: 5)
      step_id = step.id

      recipe.destroy
      expect(RecipeStep.find_by(id: step_id)).to be_nil
    end
  end

  describe 'normalized schema - equipment' do
    let(:recipe) { create(:recipe) }

    it 'can have multiple equipment items' do
      pan = Equipment.find_or_create_by!(canonical_name: 'pan')
      knife = Equipment.find_or_create_by!(canonical_name: 'knife')

      recipe.recipe_equipment.create!(equipment_id: pan.id)
      recipe.recipe_equipment.create!(equipment_id: knife.id)

      expect(recipe.equipment.count).to eq(2)
      expect(recipe.equipment.pluck(:canonical_name)).to match_array(['pan', 'knife'])
    end

    it 'supports optional equipment flag' do
      pan = Equipment.find_or_create_by!(canonical_name: 'pan')
      optional_whisk = Equipment.find_or_create_by!(canonical_name: 'whisk')

      recipe.recipe_equipment.create!(equipment_id: pan.id, optional: false)
      recipe.recipe_equipment.create!(equipment_id: optional_whisk.id, optional: true)

      required = recipe.recipe_equipment.find_by(equipment_id: pan.id)
      optional = recipe.recipe_equipment.find_by(equipment_id: optional_whisk.id)

      expect(required.optional).to be false
      expect(optional.optional).to be true
    end

    it 'cascades delete when recipe is deleted' do
      pan = Equipment.find_or_create_by!(canonical_name: 'pan')
      recipe_equipment = recipe.recipe_equipment.create!(equipment_id: pan.id)
      recipe_equipment_id = recipe_equipment.id

      recipe.destroy
      expect(RecipeEquipment.find_by(id: recipe_equipment_id)).to be_nil
    end
  end

  describe 'normalized schema - recipe nutrition' do
    let(:recipe) { create(:recipe) }

    it 'can have nutrition data with all macros' do
      nutrition = recipe.create_recipe_nutrition!(
        calories: BigDecimal('350.50'),
        protein_g: BigDecimal('25.00'),
        carbs_g: BigDecimal('40.00'),
        fat_g: BigDecimal('12.50'),
        fiber_g: BigDecimal('5.00'),
        sodium_mg: BigDecimal('450.00'),
        sugar_g: BigDecimal('8.50')
      )

      expect(recipe.recipe_nutrition).to eq(nutrition)
      expect(nutrition.calories).to eq(BigDecimal('350.50'))
      expect(nutrition.protein_g).to eq(BigDecimal('25.00'))
      expect(nutrition.carbs_g).to eq(BigDecimal('40.00'))
      expect(nutrition.fat_g).to eq(BigDecimal('12.50'))
      expect(nutrition.fiber_g).to eq(BigDecimal('5.00'))
      expect(nutrition.sodium_mg).to eq(BigDecimal('450.00'))
      expect(nutrition.sugar_g).to eq(BigDecimal('8.50'))
    end

    it 'cascades delete when recipe is deleted' do
      nutrition = recipe.create_recipe_nutrition!(calories: 300)
      nutrition_id = nutrition.id

      recipe.destroy
      expect(RecipeNutrition.find_by(id: nutrition_id)).to be_nil
    end
  end

  describe 'normalized schema - reference data associations' do
    let(:recipe) { create(:recipe) }

    describe 'dietary tags' do
      it 'can have multiple dietary tags' do
        vegetarian = DataReference.find_or_create_by(reference_type: 'dietary_tag', key: 'vegetarian') { |r| r.display_name = 'Vegetarian' }
        gluten_free = DataReference.find_or_create_by(reference_type: 'dietary_tag', key: 'gluten-free') { |r| r.display_name = 'Gluten Free' }

        recipe.recipe_dietary_tags.create!(data_reference_id: vegetarian.id)
        recipe.recipe_dietary_tags.create!(data_reference_id: gluten_free.id)

        expect(recipe.dietary_tags.count).to eq(2)
        expect(recipe.dietary_tags.pluck(:key)).to match_array(['vegetarian', 'gluten-free'])
      end

      it 'cascades delete when recipe is deleted' do
        vegetarian = DataReference.find_or_create_by(reference_type: 'dietary_tag', key: 'vegetarian') { |r| r.display_name = 'Vegetarian' }
        recipe.recipe_dietary_tags.create!(data_reference_id: vegetarian.id)

        recipe.destroy
        expect(recipe.recipe_dietary_tags.count).to eq(0)
      end
    end

    describe 'dish types' do
      it 'can have multiple dish types' do
        main_course = DataReference.find_or_create_by(reference_type: 'dish_type', key: 'main-course') { |r| r.display_name = 'Main Course' }
        side_dish = DataReference.find_or_create_by(reference_type: 'dish_type', key: 'side-dish') { |r| r.display_name = 'Side Dish' }

        recipe.recipe_dish_types.create!(data_reference_id: main_course.id)
        recipe.recipe_dish_types.create!(data_reference_id: side_dish.id)

        expect(recipe.dish_types.count).to eq(2)
        expect(recipe.dish_types.pluck(:key)).to match_array(['main-course', 'side-dish'])
      end
    end

    describe 'cuisines' do
      it 'can have multiple cuisines' do
        japanese = DataReference.find_or_create_by(reference_type: 'cuisine', key: 'japanese') { |r| r.display_name = 'Japanese' }
        italian = DataReference.find_or_create_by(reference_type: 'cuisine', key: 'italian') { |r| r.display_name = 'Italian' }

        recipe.recipe_cuisines.create!(data_reference_id: japanese.id)
        recipe.recipe_cuisines.create!(data_reference_id: italian.id)

        expect(recipe.cuisines.count).to eq(2)
        expect(recipe.cuisines.pluck(:key)).to match_array(['japanese', 'italian'])
      end
    end

    describe 'recipe types' do
      it 'can have multiple recipe types' do
        quick = DataReference.find_or_create_by(reference_type: 'recipe_type', key: 'quick-weeknight') { |r| r.display_name = 'Quick Weeknight' }
        slow_cooker = DataReference.find_or_create_by(reference_type: 'recipe_type', key: 'slow-cooker') { |r| r.display_name = 'Slow Cooker' }

        recipe.recipe_recipe_types.create!(data_reference_id: quick.id)
        recipe.recipe_recipe_types.create!(data_reference_id: slow_cooker.id)

        expect(recipe.recipe_types.count).to eq(2)
        expect(recipe.recipe_types.pluck(:key)).to match_array(['quick-weeknight', 'slow-cooker'])
      end
    end
  end

  describe 'normalized schema - recipe aliases' do
    let(:recipe) { create(:recipe) }

    it 'can have recipe aliases in multiple languages' do
      recipe.recipe_aliases.create!(alias_name: 'Chicken and Egg Bowl', language: 'en')
      recipe.recipe_aliases.create!(alias_name: 'チキンエッグどんぶり', language: 'ja')

      expect(recipe.recipe_aliases.count).to eq(2)
      expect(recipe.recipe_aliases.find_by(language: 'en').alias_name).to eq('Chicken and Egg Bowl')
      expect(recipe.recipe_aliases.find_by(language: 'ja').alias_name).to eq('チキンエッグどんぶり')
    end

    it 'cascades delete when recipe is deleted' do
      alias1 = recipe.recipe_aliases.create!(alias_name: 'Alias 1', language: 'en')
      alias_id = alias1.id

      recipe.destroy
      expect(RecipeAlias.find_by(id: alias_id)).to be_nil
    end
  end

  describe 'normalized schema - all fields' do
    let(:recipe) do
      create(:recipe,
        source_language: 'en',
        servings_original: 4,
        servings_min: 2,
        servings_max: 8,
        prep_minutes: 15,
        cook_minutes: 30,
        total_minutes: 45,
        requires_precision: true,
        precision_reason: 'baking',
        source_url: 'https://example.com/recipe',
        admin_notes: 'Great recipe for beginners',
        variants_generated: false,
        translations_completed: false
      )
    end

    it 'stores all recipe fields correctly' do
      expect(recipe.source_language).to eq('en')
      expect(recipe.servings_original).to eq(4)
      expect(recipe.servings_min).to eq(2)
      expect(recipe.servings_max).to eq(8)
      expect(recipe.prep_minutes).to eq(15)
      expect(recipe.cook_minutes).to eq(30)
      expect(recipe.total_minutes).to eq(45)
      expect(recipe.requires_precision).to be true
      expect(recipe.precision_reason).to eq('baking')
      expect(recipe.source_url).to eq('https://example.com/recipe')
      expect(recipe.admin_notes).to eq('Great recipe for beginners')
      expect(recipe.variants_generated).to be false
      expect(recipe.translations_completed).to be false
    end

    it 'supports null/missing timing fields' do
      recipe_no_prep = create(:recipe, prep_minutes: nil, cook_minutes: 20, total_minutes: 25)

      expect(recipe_no_prep.prep_minutes).to be_nil
      expect(recipe_no_prep.cook_minutes).to eq(20)
      expect(recipe_no_prep.total_minutes).to eq(25)
    end

    it 'supports null/missing servings fields' do
      recipe_no_servings = create(:recipe, servings_original: nil, servings_min: nil, servings_max: nil)

      expect(recipe_no_servings.servings_original).to be_nil
      expect(recipe_no_servings.servings_min).to be_nil
      expect(recipe_no_servings.servings_max).to be_nil
    end
  end

  describe 'normalized schema - comprehensive integration' do
    let(:recipe) { create(:recipe) }

    it 'supports full recipe with all normalized components' do
      # Create ingredient group
      group = recipe.ingredient_groups.create!(name: 'Main Ingredients', position: 1)

      # Create ingredients
      chicken = Ingredient.find_or_create_by!(canonical_name: 'chicken') { |i| i.category = 'protein' }
      eggs = Ingredient.find_or_create_by!(canonical_name: 'eggs') { |i| i.category = 'protein' }

      # Add recipe ingredients
      group.recipe_ingredients.create!(
        ingredient_id: chicken.id,
        ingredient_name: 'chicken',
        amount: 300,
        unit: 'g',
        position: 1
      )
      group.recipe_ingredients.create!(
        ingredient_id: eggs.id,
        ingredient_name: 'eggs',
        amount: 3,
        unit: 'whole',
        position: 2
      )

      # Add recipe steps
      recipe.recipe_steps.create!(step_number: 1, timing_minutes: 5)
      recipe.recipe_steps.create!(step_number: 2, timing_minutes: 10)

      # Add equipment
      pan = Equipment.find_or_create_by!(canonical_name: 'pan')
      recipe.recipe_equipment.create!(equipment_id: pan.id, optional: false)

      # Add nutrition
      recipe.create_recipe_nutrition!(
        calories: 400,
        protein_g: 35,
        carbs_g: 20,
        fat_g: 15,
        fiber_g: 2
      )

      # Add dietary tag
      vegetarian = DataReference.find_or_create_by(reference_type: 'dietary_tag', key: 'vegetarian') { |r| r.display_name = 'Vegetarian' }
      recipe.recipe_dietary_tags.create!(data_reference_id: vegetarian.id)

      # Add cuisine
      japanese = DataReference.find_or_create_by(reference_type: 'cuisine', key: 'japanese') { |r| r.display_name = 'Japanese' }
      recipe.recipe_cuisines.create!(data_reference_id: japanese.id)

      # Add alias
      recipe.recipe_aliases.create!(alias_name: 'Chicken and Egg Bowl', language: 'en')

      # Verify everything is connected
      expect(recipe.ingredient_groups.count).to eq(1)
      expect(recipe.recipe_ingredients.count).to eq(2)
      expect(recipe.recipe_steps.count).to eq(2)
      expect(recipe.equipment.count).to eq(1)
      expect(recipe.recipe_nutrition).not_to be_nil
      expect(recipe.dietary_tags.count).to eq(1)
      expect(recipe.cuisines.count).to eq(1)
      expect(recipe.recipe_aliases.count).to eq(1)

      # Verify data integrity
      first_ingredient = recipe.recipe_ingredients.first
      expect(first_ingredient.ingredient_id).to eq(chicken.id)
      expect(first_ingredient.ingredient_name).to eq('chicken')

      first_step = recipe.recipe_steps.first
      expect(first_step.step_number).to eq(1)
      expect(first_step.timing_minutes).to eq(5)

      expect(recipe.equipment.first.canonical_name).to eq('pan')
      expect(recipe.dietary_tags.first.key).to eq('vegetarian')
      expect(recipe.cuisines.first.key).to eq('japanese')
    end
  end

  describe 'data integrity' do
    it 'deletes dependent records when recipe is deleted' do
      recipe = create(:recipe)
      group = recipe.ingredient_groups.create!(name: 'Test', position: 1)
      ingredient = Ingredient.find_or_create_by!(canonical_name: 'test') { |i| i.category = 'other' }
      group.recipe_ingredients.create!(
        ingredient_id: ingredient.id,
        ingredient_name: 'test',
        position: 1
      )
      recipe.recipe_steps.create!(step_number: 1, timing_minutes: 5)

      recipe_id = recipe.id
      recipe.destroy

      expect(Recipe.find_by(id: recipe_id)).to be_nil
      expect(IngredientGroup.find_by(recipe_id: recipe_id)).to be_nil
      expect(RecipeIngredient.where(ingredient_group_id: group.id)).to be_empty
      expect(RecipeStep.find_by(recipe_id: recipe_id)).to be_nil
    end

    it 'maintains referential integrity with ingredient' do
      recipe = create(:recipe)
      group = recipe.ingredient_groups.create!(name: 'Test', position: 1)
      ingredient = Ingredient.find_or_create_by!(canonical_name: 'chicken') { |i| i.category = 'protein' }

      recipe_ingredient = group.recipe_ingredients.create!(
        ingredient_id: ingredient.id,
        ingredient_name: 'chicken',
        position: 1
      )

      expect(recipe_ingredient.ingredient).to eq(ingredient)
      expect(ingredient.recipe_ingredients).to include(recipe_ingredient)
    end

    it 'maintains referential integrity with equipment' do
      recipe = create(:recipe)
      pan = Equipment.find_or_create_by!(canonical_name: 'pan')

      recipe_equipment = recipe.recipe_equipment.create!(equipment_id: pan.id)

      expect(recipe_equipment.equipment).to eq(pan)
      expect(pan.recipes).to include(recipe)
    end

    it 'maintains referential integrity with data references' do
      recipe = create(:recipe)
      vegetarian = DataReference.find_or_create_by(reference_type: 'dietary_tag', key: 'vegetarian') { |r| r.display_name = 'Vegetarian' }

      recipe.recipe_dietary_tags.create!(data_reference_id: vegetarian.id)

      expect(recipe.dietary_tags).to include(vegetarian)
      expect(vegetarian.recipes_as_dietary_tag).to include(recipe)
    end
  end
end
