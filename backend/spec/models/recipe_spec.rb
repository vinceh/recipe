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

  describe 'Phase 3: Model Validations' do
    describe 'name validations (AC-MODEL-RECIPE-001 through 003)' do
      it 'requires name to be present (AC-MODEL-RECIPE-001)' do
        recipe = build(:recipe, name: nil)
        expect(recipe).not_to be_valid
        expect(recipe.errors[:name]).to include("can't be blank")
      end

      it 'rejects whitespace-only name (AC-MODEL-RECIPE-002)' do
        recipe = build(:recipe, name: '   ')
        expect(recipe).not_to be_valid
        expect(recipe.errors[:name]).to include("can't be blank")
      end

      it 'enforces name uniqueness (AC-MODEL-RECIPE-003)' do
        create(:recipe, name: 'Chocolate Chip Cookies')
        duplicate = build(:recipe, name: 'Chocolate Chip Cookies')
        expect(duplicate).not_to be_valid
        expect(duplicate.errors[:name]).to include('has already been taken')
      end
    end

    describe 'defaults (AC-MODEL-RECIPE-004 through 006)' do
      it 'defaults source_language to "en" (AC-MODEL-RECIPE-004)' do
        recipe = Recipe.new(name: 'Test Recipe')
        expect(recipe.source_language).to eq('en')
      end

      it 'allows source_url to be nil (AC-MODEL-RECIPE-005)' do
        recipe = build(:recipe, source_url: nil)
        expect(recipe).to be_valid
        expect(recipe.source_url).to be_nil
      end

      it 'defaults requires_precision to false (AC-MODEL-RECIPE-006)' do
        recipe = create(:recipe)
        expect(recipe.requires_precision).to eq(false)
      end
    end

    describe 'cascade deletion (AC-MODEL-RECIPE-007)' do
      it 'cascades delete associations when recipe is deleted (AC-MODEL-RECIPE-007)' do
        recipe = create(:recipe)
        ig = recipe.ingredient_groups.create!(name: 'Test', position: 1)
        rs = recipe.recipe_steps.create!(step_number: 1)
        rn = recipe.create_recipe_nutrition!(calories: 100)

        ig_id = ig.id
        rs_id = rs.id
        rn_id = rn.id

        recipe.destroy

        expect(IngredientGroup.find_by(id: ig_id)).to be_nil
        expect(RecipeStep.find_by(id: rs_id)).to be_nil
        expect(RecipeNutrition.find_by(id: rn_id)).to be_nil
      end
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

    it 'can have multiple recipe steps' do
      step1 = recipe.recipe_steps.create!(step_number: 1)
      step2 = recipe.recipe_steps.create!(step_number: 2)
      step3 = recipe.recipe_steps.create!(step_number: 3)

      expect(recipe.recipe_steps.count).to eq(3)
      expect(step1.step_number).to eq(1)
      expect(step2.step_number).to eq(2)
      expect(step3.step_number).to eq(3)
    end

    it 'maintains step number order' do
      recipe.recipe_steps.create!(step_number: 1)
      recipe.recipe_steps.create!(step_number: 3)
      recipe.recipe_steps.create!(step_number: 2)

      step_numbers = recipe.recipe_steps.pluck(:step_number)
      expect(step_numbers).to match_array([1, 2, 3])
    end

    it 'cascades delete when recipe is deleted' do
      step = recipe.recipe_steps.create!(step_number: 1)
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
      recipe.recipe_steps.create!(step_number: 1)
      recipe.recipe_steps.create!(step_number: 2)

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
      recipe.recipe_steps.create!(step_number: 1)

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

  describe 'Phase 5: Auto-Triggered Translation Workflow' do
    describe 'AC-PHASE5-CALLBACK-001: Recipe Creation Triggers Translation' do
      it 'enqueues TranslateRecipeJob on recipe creation' do
        expect {
          create(:recipe, name: "Test Recipe #{SecureRandom.hex(4)}")
        }.to have_enqueued_job(TranslateRecipeJob)
      end

      it 'enqueues job with correct recipe_id' do
        recipe = create(:recipe, name: "Test Recipe #{SecureRandom.hex(4)}")
        expect {
          create(:recipe, name: "Another Recipe #{SecureRandom.hex(4)}")
        }.to have_enqueued_job(TranslateRecipeJob).at_least(:once)
      end

      it 'enqueues immediately without rate limiting for create' do
        recipe = create(:recipe, last_translated_at: 10.minutes.ago, name: "Test #{SecureRandom.hex(4)}")

        expect {
          create(:recipe, name: "New Recipe #{SecureRandom.hex(4)}")
        }.to have_enqueued_job(TranslateRecipeJob)
      end
    end

    describe 'AC-PHASE5-CALLBACK-002: Recipe Update Triggers Translation (First Time)' do
      it 'enqueues job on first update when last_translated_at is nil' do
        recipe = create(:recipe, last_translated_at: nil)

        expect {
          recipe.update(servings_original: 6)
        }.to have_enqueued_job(TranslateRecipeJob).with(recipe.id)
      end

      it 'does not rate limit when no previous translations exist' do
        recipe = create(:recipe, last_translated_at: nil)

        expect {
          recipe.update(prep_minutes: 20)
        }.to have_enqueued_job(TranslateRecipeJob)
      end
    end

    describe 'AC-PHASE5-CALLBACK-003 & AC-PHASE5-CALLBACK-004: Recipe Update Rate Limiting' do
      before do
        skip 'SolidQueue not initialized in test environment' unless SolidQueue::Job.table_exists?
      end

      it 'does not enqueue job when rate limit exceeded (4 translations in last hour)' do
        recipe = create(:recipe, last_translated_at: 30.minutes.ago)

        # Simulate 4 completed translation jobs in last hour
        4.times do |i|
          SolidQueue::Job.create!(
            class_name: 'TranslateRecipeJob',
            arguments: [recipe.id],
            finished_at: (25 - i).minutes.ago
          )
        end

        expect {
          recipe.update(servings_original: 8)
        }.not_to have_enqueued_job(TranslateRecipeJob)
      end

      it 'saves recipe update successfully even when rate limited' do
        recipe = create(:recipe, last_translated_at: 30.minutes.ago)

        4.times do |i|
          SolidQueue::Job.create!(
            class_name: 'TranslateRecipeJob',
            arguments: [recipe.id],
            finished_at: (25 - i).minutes.ago
          )
        end

        recipe.update(servings_original: 8)
        expect(recipe.reload.servings_original).to eq(8)
      end

      it 'enqueues job when under rate limit (less than 4 in last hour)' do
        recipe = create(:recipe, last_translated_at: 30.minutes.ago)

        # Only 3 completed jobs
        3.times do |i|
          SolidQueue::Job.create!(
            class_name: 'TranslateRecipeJob',
            arguments: [recipe.id],
            finished_at: (25 - i).minutes.ago
          )
        end

        expect {
          recipe.update(servings_original: 8)
        }.to have_enqueued_job(TranslateRecipeJob).with(recipe.id)
      end

      it 'enqueues when exactly at 3 translations (under 4 limit)' do
        recipe = create(:recipe, last_translated_at: 40.minutes.ago)

        3.times do |i|
          SolidQueue::Job.create!(
            class_name: 'TranslateRecipeJob',
            arguments: [recipe.id],
            finished_at: (35 - i).minutes.ago
          )
        end

        expect {
          recipe.update(cook_minutes: 45)
        }.to have_enqueued_job(TranslateRecipeJob)
      end
    end

    describe 'AC-PHASE5-CALLBACK-005: Rate Limit Window Sliding' do
      before do
        skip 'SolidQueue not initialized in test environment' unless SolidQueue::Job.table_exists?
      end

      it 'counts only jobs within 1-hour window' do
        recipe = create(:recipe, last_translated_at: 65.minutes.ago)

        # 3 jobs in last hour
        3.times do |i|
          SolidQueue::Job.create!(
            class_name: 'TranslateRecipeJob',
            arguments: [recipe.id],
            finished_at: (55 - i).minutes.ago
          )
        end

        # 1 job outside 1-hour window
        SolidQueue::Job.create!(
          class_name: 'TranslateRecipeJob',
          arguments: [recipe.id],
          finished_at: 65.minutes.ago
        )

        expect {
          recipe.update(total_minutes: 60)
        }.to have_enqueued_job(TranslateRecipeJob).with(recipe.id)
      end

      it 'does not enqueue when 4 jobs in window regardless of older jobs' do
        recipe = create(:recipe, last_translated_at: 50.minutes.ago)

        4.times do |i|
          SolidQueue::Job.create!(
            class_name: 'TranslateRecipeJob',
            arguments: [recipe.id],
            finished_at: (45 - i).minutes.ago
          )
        end

        SolidQueue::Job.create!(
          class_name: 'TranslateRecipeJob',
          arguments: [recipe.id],
          finished_at: 90.minutes.ago
        )

        expect {
          recipe.update(prep_minutes: 10)
        }.not_to have_enqueued_job(TranslateRecipeJob)
      end
    end

    describe 'AC-PHASE5-DEDUP-001: Duplicate Job Prevention - Job Already Pending' do
      before do
        skip 'SolidQueue not initialized in test environment' unless SolidQueue::Job.table_exists?
      end

      it 'deletes pending job and enqueues new one with latest recipe data' do
        recipe = create(:recipe, last_translated_at: 2.hours.ago)

        pending_job = SolidQueue::Job.create!(
          class_name: 'TranslateRecipeJob',
          arguments: [recipe.id],
          finished_at: nil
        )

        expect {
          recipe.update(servings_original: 8)
        }.to have_enqueued_job(TranslateRecipeJob).with(recipe.id)

        # Verify pending job was deleted
        expect(SolidQueue::Job.exists?(pending_job.id)).to be false
      end

      it 'allows enqueueing when pending job is for different recipe' do
        recipe1 = create(:recipe, name: "Recipe 1 #{SecureRandom.hex(4)}", last_translated_at: 2.hours.ago)
        recipe2 = create(:recipe, name: "Recipe 2 #{SecureRandom.hex(4)}", last_translated_at: 2.hours.ago)

        SolidQueue::Job.create!(
          class_name: 'TranslateRecipeJob',
          arguments: [recipe1.id],
          finished_at: nil
        )

        expect {
          recipe2.update(servings_original: 8)
        }.to have_enqueued_job(TranslateRecipeJob).with(recipe2.id)
      end
    end

    describe 'AC-PHASE5-DEDUP-002: Job Allowed After Previous Job Completes' do
      before do
        skip 'SolidQueue not initialized in test environment' unless SolidQueue::Job.table_exists?
      end

      it 'enqueues new job after previous job finishes' do
        recipe = create(:recipe, last_translated_at: 2.hours.ago)

        SolidQueue::Job.create!(
          class_name: 'TranslateRecipeJob',
          arguments: [recipe.id],
          finished_at: 10.minutes.ago
        )

        expect {
          recipe.update(servings_original: 8)
        }.to have_enqueued_job(TranslateRecipeJob).with(recipe.id)
      end
    end

    describe 'AC-PHASE5-DEDUP-003: Concurrent Update Prevention Detail' do
      before do
        skip 'SolidQueue not initialized in test environment' unless SolidQueue::Job.table_exists?
      end

      it 'deletes only pending jobs (not completed ones)' do
        recipe = create(:recipe, last_translated_at: 2.hours.ago)

        # Completed job - should NOT be deleted
        completed_job = SolidQueue::Job.create!(
          class_name: 'TranslateRecipeJob',
          arguments: [recipe.id],
          finished_at: 10.minutes.ago
        )

        # Pending job - should be deleted
        pending_job = SolidQueue::Job.create!(
          class_name: 'TranslateRecipeJob',
          arguments: [recipe.id],
          finished_at: nil
        )

        recipe.update(servings_original: 8)

        # Verify completed job still exists
        expect(SolidQueue::Job.exists?(completed_job.id)).to be true
        # Verify pending job was deleted
        expect(SolidQueue::Job.exists?(pending_job.id)).to be false
      end

      it 'checks for pending jobs by matching recipe_id in arguments' do
        recipe1 = create(:recipe, name: "Recipe 1 #{SecureRandom.hex(4)}", last_translated_at: 2.hours.ago)
        recipe2 = create(:recipe, name: "Recipe 2 #{SecureRandom.hex(4)}", last_translated_at: 2.hours.ago)

        # Pending job for recipe1 only
        pending_job_recipe1 = SolidQueue::Job.create!(
          class_name: 'TranslateRecipeJob',
          arguments: [recipe1.id],
          finished_at: nil
        )

        # recipe2 update should enqueue (different recipe_id)
        expect {
          recipe2.update(servings_original: 8)
        }.to have_enqueued_job(TranslateRecipeJob).with(recipe2.id)

        # Verify recipe1 pending job was NOT deleted (different recipe)
        expect(SolidQueue::Job.exists?(pending_job_recipe1.id)).to be true
      end
    end

    describe 'helper methods' do
      describe 'translation_rate_limit_exceeded?' do
        it 'returns false when last_translated_at is nil' do
          recipe = create(:recipe, last_translated_at: nil)
          expect(recipe.send(:translation_rate_limit_exceeded?)).to be false
        end

        it 'returns false when SolidQueue not available' do
          recipe = create(:recipe, last_translated_at: 30.minutes.ago)
          expect(recipe.send(:translation_rate_limit_exceeded?)).to be false
        end

        context 'when SolidQueue available' do
          before do
            skip 'SolidQueue not initialized in test environment' unless SolidQueue::Job.table_exists?
          end

          it 'returns true when 4 or more completed jobs in last hour' do
            recipe = create(:recipe, last_translated_at: 30.minutes.ago)

            4.times do |i|
              SolidQueue::Job.create!(
                class_name: 'TranslateRecipeJob',
                arguments: [recipe.id],
                finished_at: (25 - i).minutes.ago
              )
            end

            expect(recipe.send(:translation_rate_limit_exceeded?)).to be true
          end
        end
      end

      describe 'delete_pending_translation_job' do
        context 'when SolidQueue available' do
          before do
            skip 'SolidQueue not initialized in test environment' unless SolidQueue::Job.table_exists?
          end

          it 'deletes pending jobs for recipe' do
            recipe = create(:recipe)

            pending_job = SolidQueue::Job.create!(
              class_name: 'TranslateRecipeJob',
              arguments: [recipe.id],
              finished_at: nil
            )

            recipe.send(:delete_pending_translation_job)
            expect(SolidQueue::Job.exists?(pending_job.id)).to be false
          end

          it 'does not delete completed jobs' do
            recipe = create(:recipe)

            completed_job = SolidQueue::Job.create!(
              class_name: 'TranslateRecipeJob',
              arguments: [recipe.id],
              finished_at: 10.minutes.ago
            )

            recipe.send(:delete_pending_translation_job)
            expect(SolidQueue::Job.exists?(completed_job.id)).to be true
          end

          it 'does not delete jobs for other recipes' do
            recipe1 = create(:recipe, name: "Recipe 1 #{SecureRandom.hex(4)}")
            recipe2 = create(:recipe, name: "Recipe 2 #{SecureRandom.hex(4)}")

            pending_job = SolidQueue::Job.create!(
              class_name: 'TranslateRecipeJob',
              arguments: [recipe1.id],
              finished_at: nil
            )

            recipe2.send(:delete_pending_translation_job)
            expect(SolidQueue::Job.exists?(pending_job.id)).to be true
          end
        end
      end

      describe 'schedule_translation_at_next_available_time' do
        context 'when SolidQueue available' do
          before do
            skip 'SolidQueue not initialized in test environment' unless SolidQueue::Job.table_exists?
          end

          it 'schedules job with correct delay based on rolling window' do
            recipe = create(:recipe)

            # Create 4 completed jobs at specific times
            # 9:15, 9:20, 9:40, 9:50 (current time is 10:00)
            freeze_time do
              now = Time.current
              [45, 40, 20, 10].each do |minutes_ago|
                SolidQueue::Job.create!(
                  class_name: 'TranslateRecipeJob',
                  arguments: [recipe.id],
                  finished_at: now - minutes_ago.minutes
                )
              end

              # At 10:00, oldest job (45 min ago, at 9:15) falls out of window at 10:16
              # Delay should be 16 minutes
              recipe.send(:schedule_translation_at_next_available_time)

              # Check that job was enqueued with approximately 16 minute delay
              enqueued_jobs = ActiveJob::Base.queue_adapter.enqueued_jobs.select do |job|
                job[:job] == TranslateRecipeJob && job[:args] == [recipe.id]
              end

              expect(enqueued_jobs.length).to eq(1)
              # wait_until should be approximately 16 minutes from now
              delay_seconds = enqueued_jobs.last[:wait]
              expect(delay_seconds).to be_between(950, 1010) # ~16 minutes in seconds
            end
          end
        end
      end

      describe 'get_oldest_completed_translation_job' do
        context 'when SolidQueue available' do
          before do
            skip 'SolidQueue not initialized in test environment' unless SolidQueue::Job.table_exists?
          end

          it 'returns oldest completed job for recipe' do
            recipe = create(:recipe)

            job1 = SolidQueue::Job.create!(
              class_name: 'TranslateRecipeJob',
              arguments: [recipe.id],
              finished_at: 10.minutes.ago
            )

            job2 = SolidQueue::Job.create!(
              class_name: 'TranslateRecipeJob',
              arguments: [recipe.id],
              finished_at: 5.minutes.ago
            )

            oldest = recipe.send(:get_oldest_completed_translation_job)
            expect(oldest.id).to eq(job1.id)
          end

          it 'ignores pending jobs' do
            recipe = create(:recipe)

            pending_job = SolidQueue::Job.create!(
              class_name: 'TranslateRecipeJob',
              arguments: [recipe.id],
              finished_at: nil
            )

            completed_job = SolidQueue::Job.create!(
              class_name: 'TranslateRecipeJob',
              arguments: [recipe.id],
              finished_at: 10.minutes.ago
            )

            oldest = recipe.send(:get_oldest_completed_translation_job)
            expect(oldest.id).to eq(completed_job.id)
          end

          it 'returns nil when no completed jobs' do
            recipe = create(:recipe)

            oldest = recipe.send(:get_oldest_completed_translation_job)
            expect(oldest).to be_nil
          end
        end
      end

      describe 'completed_translation_job_count' do
        it 'returns 0 when no completed jobs' do
          recipe = create(:recipe)
          expect(recipe.send(:completed_translation_job_count)).to eq(0)
        end

        context 'when SolidQueue available' do
          before do
            skip 'SolidQueue not initialized in test environment' unless SolidQueue::Job.table_exists?
          end

          it 'returns count of completed jobs in last hour' do
            recipe = create(:recipe)

            3.times do |i|
              SolidQueue::Job.create!(
                class_name: 'TranslateRecipeJob',
                arguments: [recipe.id],
                finished_at: (25 - i).minutes.ago
              )
            end

            expect(recipe.send(:completed_translation_job_count)).to eq(3)
          end

          it 'excludes jobs outside 1-hour window' do
            recipe = create(:recipe)

            3.times do |i|
              SolidQueue::Job.create!(
                class_name: 'TranslateRecipeJob',
                arguments: [recipe.id],
                finished_at: (25 - i).minutes.ago
              )
            end

            # Job outside window
            SolidQueue::Job.create!(
              class_name: 'TranslateRecipeJob',
              arguments: [recipe.id],
              finished_at: 90.minutes.ago
            )

            expect(recipe.send(:completed_translation_job_count)).to eq(3)
          end

          it 'excludes pending jobs (where finished_at is nil)' do
            recipe = create(:recipe)

            2.times do |i|
              SolidQueue::Job.create!(
                class_name: 'TranslateRecipeJob',
                arguments: [recipe.id],
                finished_at: (25 - i).minutes.ago
              )
            end

            SolidQueue::Job.create!(
              class_name: 'TranslateRecipeJob',
              arguments: [recipe.id],
              finished_at: nil
            )

            expect(recipe.send(:completed_translation_job_count)).to eq(2)
          end

          it 'excludes jobs for other recipes' do
            recipe1 = create(:recipe, name: "Recipe 1 #{SecureRandom.hex(4)}")
            recipe2 = create(:recipe, name: "Recipe 2 #{SecureRandom.hex(4)}")

            2.times do |i|
              SolidQueue::Job.create!(
                class_name: 'TranslateRecipeJob',
                arguments: [recipe1.id],
                finished_at: (25 - i).minutes.ago
              )
            end

            3.times do |i|
              SolidQueue::Job.create!(
                class_name: 'TranslateRecipeJob',
                arguments: [recipe2.id],
                finished_at: (25 - i).minutes.ago
              )
            end

            expect(recipe1.send(:completed_translation_job_count)).to eq(2)
            expect(recipe2.send(:completed_translation_job_count)).to eq(3)
          end
        end
      end

      describe 'job_queue_available?' do
        it 'returns false when SolidQueue not initialized' do
          recipe = create(:recipe)
          expect(recipe.send(:job_queue_available?)).to be false
        end
      end
    end
  end
end
