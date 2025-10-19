module Api
  module V1
    class RecipesController < BaseController
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

        # Pagination
        page = params[:page]&.to_i || 1
        per_page = params[:per_page]&.to_i || 20
        per_page = [per_page, 100].min # Max 100 per page

        paginated_recipes = recipes
          .order(created_at: :desc)
          .offset((page - 1) * per_page)
          .limit(per_page)

        total_count = recipes.count
        total_pages = (total_count.to_f / per_page).ceil

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
        recipe = Recipe.find(params[:id])
        render_success(data: { recipe: recipe_detail_json(recipe) })
      end

      # POST /api/v1/recipes/:id/scale
      # Scale recipe ingredients to new serving size
      def scale
        recipe = Recipe.find(params[:id])
        new_servings = params.require(:servings).to_f

        # Validate servings within min/max range
        min = recipe.servings['min'] || 1
        max = recipe.servings['max'] || 999

        if new_servings < min || new_servings > max
          return render_error(
            message: "Servings must be between #{min} and #{max}",
            status: :unprocessable_entity
          )
        end

        original_servings = recipe.servings['original'].to_f
        scale_factor = new_servings / original_servings

        # Scale ingredient amounts
        scaled_ingredient_groups = recipe.ingredient_groups.map do |group|
          {
            'name' => group['name'],
            'items' => group['items'].map do |item|
              original_amount = item['amount'].to_f
              scaled_amount = (original_amount * scale_factor).round(2)

              item.merge('amount' => scaled_amount.to_s)
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
          :min_servings, :max_servings
        ]

        advanced_params.any? { |param| params[param].present? }
      end

      # Apply basic search and filter parameters (backwards compatible)
      def apply_basic_search_filters(recipes)
        # Search query (name only for JSONB schema)
        if params[:q].present?
          query = "%#{params[:q]}%"
          recipes = recipes.where('recipes.name ILIKE ?', query)
        end

        # Filter by dietary tags (JSONB array contains - OR logic for multiple tags)
        if params[:dietary_tags].present?
          tag_names = params[:dietary_tags].split(',').map(&:strip)
          conditions = tag_names.map { "dietary_tags @> ?" }.join(' OR ')
          values = tag_names.map { |tag| [tag].to_json }
          recipes = recipes.where(conditions, *values)
        end

        # Filter by dish types (OR logic for multiple types)
        if params[:dish_types].present?
          type_names = params[:dish_types].split(',').map(&:strip)
          conditions = type_names.map { "dish_types @> ?" }.join(' OR ')
          values = type_names.map { |type| [type].to_json }
          recipes = recipes.where(conditions, *values)
        end

        # Filter by cuisines (OR logic for multiple cuisines)
        if params[:cuisines].present?
          cuisine_names = params[:cuisines].split(',').map(&:strip)
          conditions = cuisine_names.map { "cuisines @> ?" }.join(' OR ')
          values = cuisine_names.map { |cuisine| [cuisine].to_json }
          recipes = recipes.where(conditions, *values)
        end

        # Filter by cook time
        if params[:max_cook_time].present?
          recipes = recipes.where("(timing->>'cook_minutes')::int <= ?", params[:max_cook_time].to_i)
        end

        # Filter by prep time
        if params[:max_prep_time].present?
          recipes = recipes.where("(timing->>'prep_minutes')::int <= ?", params[:max_prep_time].to_i)
        end

        # Filter by total time
        if params[:max_total_time].present?
          recipes = recipes.where("(timing->>'total_minutes')::int <= ?", params[:max_total_time].to_i)
        end

        recipes
      end

      # JSON for recipe list (minimal data)
      def recipe_list_json(recipe)
        {
          id: recipe.id,
          name: recipe.name,
          language: recipe.language,
          servings: recipe.servings['original'],
          timing: recipe.timing,
          dietary_tags: recipe.dietary_tags,
          dish_types: recipe.dish_types,
          cuisines: recipe.cuisines,
          source_url: recipe.source_url,
          created_at: recipe.created_at,
          updated_at: recipe.updated_at
        }
      end

      # JSON for recipe detail (full data)
      def recipe_detail_json(recipe)
        {
          id: recipe.id,
          name: recipe.name,
          language: recipe.language,
          servings: recipe.servings,
          timing: recipe.timing,
          dietary_tags: recipe.dietary_tags,
          dish_types: recipe.dish_types,
          recipe_types: recipe.recipe_types,
          cuisines: recipe.cuisines,
          ingredient_groups: recipe.ingredient_groups,
          steps: recipe.steps,
          equipment: recipe.equipment,
          nutrition: recipe.nutrition,
          requires_precision: recipe.requires_precision,
          precision_reason: recipe.precision_reason,
          source_url: recipe.source_url,
          translations: recipe.translations,
          created_at: recipe.created_at,
          updated_at: recipe.updated_at
        }
      end
    end
  end
end
