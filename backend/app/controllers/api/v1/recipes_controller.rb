module Api
  module V1
    class RecipesController < BaseController
      include RecipeSerializer
      # GET /api/v1/recipes
      # List/search recipes with pagination and filtering
      def index
        # Use advanced search service if advanced filters are provided
        if use_advanced_search?
          recipes = RecipeSearchService.advanced_search(params)
        else
          recipes = Recipe.all
          recipes = apply_basic_search_filters(recipes)
        end

        # Get count before eager loading for efficiency
        total_count = recipes.count
        page = params[:page]&.to_i || 1
        per_page = params[:per_page]&.to_i || 20
        per_page = [ per_page, 100 ].min # Max 100 per page
        total_pages = (total_count.to_f / per_page).ceil

        # Eager load associations for list view
        recipes = recipes.includes(:ingredient_groups, :recipe_ingredients, :equipment, :dietary_tags, :cuisines, :recipe_steps)

        paginated_recipes = recipes
          .order(created_at: :desc)
          .offset((page - 1) * per_page)
          .limit(per_page)

        render_success(
          data: {
            recipes: paginated_recipes.map { |r| recipe_list_json(r) },
            pagination: {
              current_page: page,
              per_page: per_page,
              total_count: total_count,
              total_pages: total_pages
            }
          }
        )
      end

      # GET /api/v1/recipes/:id
      # Show single recipe with full details
      def show
        recipe = Recipe.includes(:ingredient_groups, :recipe_ingredients, :equipment, :recipe_nutrition, :dietary_tags, :cuisines, :recipe_aliases, :recipe_steps).find(params[:id])
        render_success(data: { recipe: recipe_detail_json(recipe) })
      end

      # POST /api/v1/recipes/:id/scale
      # Scale recipe ingredients to new serving size
      def scale
        recipe = Recipe.includes(:ingredient_groups, :recipe_ingredients).find(params[:id])
        new_servings = params.require(:servings).to_f

        # Validate servings within min/max range
        min = recipe.servings_min || 1
        max = recipe.servings_max || 999

        if new_servings < min || new_servings > max
          return render_error(
            message: "Servings must be between #{min} and #{max}",
            status: :unprocessable_entity
          )
        end

        original_servings = recipe.servings_original.to_f
        scale_factor = new_servings / original_servings

        # Scale ingredient amounts using normalized structure
        scaled_ingredient_groups = recipe.ingredient_groups.map do |group|
          {
            "name" => group.name,
            "items" => group.recipe_ingredients.map do |item|
              original_amount = item.amount.to_f
              scaled_amount = (original_amount * scale_factor).round(2)

              {
                "name" => item.ingredient_name,
                "amount" => scaled_amount.to_s,
                "unit" => item.unit,
                "preparation" => item.preparation_notes,
                "optional" => item.optional
              }
            end
          }
        end

        render_success(
          data: {
            original_servings: original_servings.to_i,
            new_servings: new_servings.to_i,
            scale_factor: scale_factor.round(2),
            scaled_ingredient_groups: scaled_ingredient_groups
          }
        )
      end

      private

      # Check if advanced search parameters are present
      def use_advanced_search?
        advanced_params = [
          :ingredient, :exclude_ingredients,
          :min_calories, :max_calories, :min_protein, :max_carbs, :max_fat,
          :min_servings, :max_servings,
          :difficulty_level
        ]

        advanced_params.any? { |param| params[param].present? }
      end

      # Apply basic search and filter parameters (backwards compatible)
      def apply_basic_search_filters(recipes)
        # Search query (name only) - find matching recipe IDs from translation table
        if params[:q].present?
          query = "%#{params[:q]}%"
          matching_ids = RecipeTranslation.where("name ILIKE ?", query).pluck(:recipe_id)
          recipes = recipes.where(id: matching_ids)
        end

        # Filter by dietary tags
        if params[:dietary_tags].present?
          tag_names = params[:dietary_tags].split(",").map(&:strip)
          tag_ids = DataReferenceTranslation.where(display_name: tag_names, data_reference_id: DataReference.where(reference_type: "dietary_tag").pluck(:id)).distinct.pluck(:data_reference_id)
          recipes = recipes.joins(:recipe_dietary_tags).where(recipe_dietary_tags: { data_reference_id: tag_ids }).distinct
        end

        # Filter by cuisines
        if params[:cuisines].present?
          cuisine_names = params[:cuisines].split(",").map(&:strip)
          cuisine_ids = DataReferenceTranslation.where(display_name: cuisine_names, data_reference_id: DataReference.where(reference_type: "cuisine").pluck(:id)).distinct.pluck(:data_reference_id)
          recipes = recipes.joins(:recipe_cuisines).where(recipe_cuisines: { data_reference_id: cuisine_ids }).distinct
        end

        # Filter by cook time
        if params[:max_cook_time].present?
          recipes = recipes.where("cook_minutes <= ?", params[:max_cook_time].to_i)
        end

        # Filter by prep time
        if params[:max_prep_time].present?
          recipes = recipes.where("prep_minutes <= ?", params[:max_prep_time].to_i)
        end

        # Filter by total time
        if params[:max_total_time].present?
          recipes = recipes.where("total_minutes <= ?", params[:max_total_time].to_i)
        end

        # Filter by difficulty level
        if params[:difficulty_level].present?
          recipes = recipes.where(difficulty_level: params[:difficulty_level])
        end

        recipes
      end

      # JSON for recipe list (minimal data)
      def recipe_list_json(recipe)
        {
          id: recipe.id,
          name: recipe.name,
          description: recipe.description,
          language: recipe.source_language,
          image_url: recipe.image.attached? ? rails_blob_url(recipe.image, only_path: false) : nil,
          servings: {
            original: recipe.servings_original,
            min: recipe.servings_min,
            max: recipe.servings_max
          },
          timing: {
            prep_minutes: recipe.prep_minutes,
            cook_minutes: recipe.cook_minutes,
            total_minutes: recipe.total_minutes
          },
          dietary_tags: recipe.dietary_tags.map(&:display_name).compact,
          cuisines: recipe.cuisines.map(&:display_name).compact,
          source_url: recipe.source_url,
          difficulty_level: recipe.difficulty_level,
          translations_completed: recipe.translations_completed,
          last_translated_at: recipe.last_translated_at,
          created_at: recipe.created_at,
          updated_at: recipe.updated_at
        }
      end

      # JSON for recipe detail (full data)
      def recipe_detail_json(recipe)
        {
          id: recipe.id,
          name: recipe.name,
          description: recipe.description,
          language: recipe.source_language,
          image_url: recipe.image.attached? ? rails_blob_url(recipe.image, only_path: false) : nil,
          servings: {
            original: recipe.servings_original,
            min: recipe.servings_min,
            max: recipe.servings_max
          },
          timing: {
            prep_minutes: recipe.prep_minutes,
            cook_minutes: recipe.cook_minutes,
            total_minutes: recipe.total_minutes
          },
          dietary_tags: recipe.dietary_tags.map(&:display_name).compact,
          cuisines: recipe.cuisines.map(&:display_name).compact,
          ingredient_groups: serialize_ingredient_groups(recipe),
          steps: serialize_recipe_steps(recipe),
          equipment: recipe.equipment.map(&:canonical_name).compact,
          nutrition: recipe.recipe_nutrition ? serialize_nutrition(recipe.recipe_nutrition) : nil,
          requires_precision: recipe.requires_precision,
          precision_reason: recipe.precision_reason,
          difficulty_level: recipe.difficulty_level,
          source_url: recipe.source_url,
          translations_completed: recipe.translations_completed,
          last_translated_at: recipe.last_translated_at,
          created_at: recipe.created_at,
          updated_at: recipe.updated_at
        }
      end
    end
  end
end
