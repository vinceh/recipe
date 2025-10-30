module Admin
  class RecipesController < BaseController
    include RecipeSerializer
    # GET /admin/recipes
    # List all recipes with admin filters
    def index
      recipes = Recipe.all.order(created_at: :desc)

      # Apply admin-specific filters
      if params[:q].present?
        recipes = recipes.where("LOWER(name) LIKE ?", "%#{params[:q].downcase}%")
      end

      # Filter by cuisines (multiple)
      if params[:cuisines].present?
        cuisine_names = params[:cuisines].is_a?(Array) ? params[:cuisines] : [ params[:cuisines] ]
        cuisine_ids = DataReference.where(reference_type: "cuisine", display_name: cuisine_names).pluck(:id)
        recipes = recipes.joins(:recipe_cuisines).where(recipe_cuisines: { data_reference_id: cuisine_ids }).distinct
      elsif params[:cuisine].present?
        cuisine_id = DataReference.where(reference_type: "cuisine", display_name: params[:cuisine]).pluck(:id).first
        recipes = recipes.joins(:recipe_cuisines).where(recipe_cuisines: { data_reference_id: cuisine_id }).distinct if cuisine_id
      end

      # Filter by max prep time
      if params[:max_prep_time].present?
        max_time = params[:max_prep_time].to_i
        recipes = recipes.where("prep_minutes <= ?", max_time)
      end

      # Filter by dietary tag
      if params[:dietary_tag].present?
        tag_id = DataReference.where(reference_type: "dietary_tag", display_name: params[:dietary_tag]).pluck(:id).first
        recipes = recipes.joins(:recipe_dietary_tags).where(recipe_dietary_tags: { data_reference_id: tag_id }).distinct if tag_id
      end

      # Filter by difficulty level
      if params[:difficulty_level].present?
        recipes = recipes.where(difficulty_level: params[:difficulty_level])
      end

      # Get count before eager loading for efficiency
      total_count = recipes.count
      page = params[:page]&.to_i || 1
      per_page = params[:per_page]&.to_i || 20
      per_page = [ per_page, 100 ].min
      total_pages = (total_count.to_f / per_page).ceil

      # Eager load associations for serialization
      recipes = recipes.includes(:ingredient_groups, :recipe_ingredients, :equipment, :recipe_nutrition, :dietary_tags, :cuisines, recipe_steps: :translations)

      paginated_recipes = recipes
        .offset((page - 1) * per_page)
        .limit(per_page)

      render_success(
        data: {
          recipes: paginated_recipes.map { |r| admin_recipe_json(r) },
          pagination: {
            current_page: page,
            per_page: per_page,
            total_count: total_count,
            total_pages: total_pages
          }
        }
      )
    end

    # GET /admin/recipes/:id
    # Show a single recipe with full details
    def show
      recipe = Recipe.includes(:ingredient_groups, :recipe_ingredients, :equipment, :recipe_nutrition, :dietary_tags, :cuisines, :recipe_aliases, recipe_steps: :translations).find(params[:id])

      render_success(
        data: { recipe: admin_recipe_json_full(recipe) }
      )
    end

    # POST /admin/recipes
    # AC-ADMIN-001: Manual recipe creation
    def create
      recipe = Recipe.new(recipe_params)

      if recipe.save
        render_success(
          data: { recipe: admin_recipe_json(recipe) },
          message: "Recipe created successfully",
          status: :created
        )
      else
        render_error(
          message: "Failed to create recipe",
          errors: recipe.errors.full_messages
        )
      end
    end

    # PUT /admin/recipes/:id
    # Update recipe
    def update
      recipe = Recipe.find(params[:id])

      if recipe.update(recipe_params)
        render_success(
          data: { recipe: admin_recipe_json(recipe) },
          message: "Recipe updated successfully"
        )
      else
        render_error(
          message: "Failed to update recipe",
          errors: recipe.errors.full_messages
        )
      end
    end

    # DELETE /admin/recipes/:id
    # Delete recipe
    def destroy
      recipe = Recipe.find(params[:id])
      recipe.destroy!

      render_success(
        data: { deleted: true },
        message: "Recipe deleted successfully"
      )
    end

    # POST /admin/recipes/parse_text
    # AC-ADMIN-002: Parse recipe from text block
    def parse_text
      text_content = params.require(:text_content)
      handle_parse('text') { |parser| parser.parse_text_block(text_content) }
    end

    # POST /admin/recipes/parse_url
    # AC-ADMIN-003: Parse recipe from URL
    def parse_url
      url = params.require(:url)
      handle_parse('URL') { |parser| parser.parse_url(url) }
    end

    # POST /admin/recipes/:id/regenerate_translations
    # AC-ADMIN-008: Regenerate translations
    def regenerate_translations
      recipe = Recipe.find(params[:id])

      # Bypass rate limiting and deduplication by directly enqueueing the job
      TranslateRecipeJob.perform_later(recipe.id)

      render_success(
        data: { recipe: admin_recipe_json(recipe) },
        message: "Translation regeneration queued"
      )
    end

    # POST /admin/recipes/check_duplicates
    # AC-ADMIN-005 & AC-ADMIN-006: Check for duplicate recipes
    def check_duplicates
      name = params.require(:name)
      aliases = params[:aliases] || []

      # Find similar recipes by name
      similar_by_name = RecipeSearchService.fuzzy_search(name, similarity_threshold: 0.85)

      # Find recipes matching aliases
      similar_by_alias = []
      aliases.each do |alias_name|
        similar_by_alias += RecipeSearchService.search_by_alias(alias_name).to_a
      end

      all_similar = (similar_by_name.to_a + similar_by_alias).uniq

      if all_similar.any?
        render_success(
          data: {
            has_duplicates: true,
            similar_recipes: all_similar.map do |recipe|
              {
                id: recipe.id,
                name: recipe.name,
                aliases: recipe.aliases,
                created_at: recipe.created_at
              }
            end
          }
        )
      else
        render_success(
          data: {
            has_duplicates: false,
            similar_recipes: []
          }
        )
      end
    end

    # DELETE /admin/recipes/bulk_delete
    # AC-ADMIN-009: Bulk delete recipes
    def bulk_delete
      recipe_ids = params.require(:recipe_ids)

      unless recipe_ids.is_a?(Array)
        return render_error(
          message: "recipe_ids must be an array",
          status: :bad_request
        )
      end

      deleted_count = Recipe.where(id: recipe_ids).count
      Recipe.where(id: recipe_ids).destroy_all

      render_success(
        data: {
          deleted_count: deleted_count
        },
        message: "#{deleted_count} recipe(s) deleted successfully"
      )
    end

    private

    def recipe_params
      params.require(:recipe).permit(
        :name,
        :description,
        :source_language,
        :requires_precision,
        :precision_reason,
        :difficulty_level,
        :source_url,
        :admin_notes,
        :translations_completed,
        :image,
        :servings_original,
        :servings_min,
        :servings_max,
        :prep_minutes,
        :cook_minutes,
        :total_minutes,
        ingredient_groups_attributes: [
          :id, :name, :position, :_destroy,
          recipe_ingredients_attributes: [
            :id, :ingredient_id, :ingredient_name, :amount, :unit, :preparation_notes, :optional, :position, :_destroy
          ]
        ],
        recipe_steps_attributes: [
          :id, :step_number, :instruction_original, :_destroy
        ],
        recipe_nutrition_attributes: [
          :id, :calories, :protein_g, :carbs_g, :fat_g, :fiber_g, :sodium_mg, :sugar_g, :_destroy
        ],
        recipe_equipment_attributes: [
          :id, :equipment_id, :optional, :_destroy
        ],
        recipe_dietary_tags_attributes: [
          :id, :data_reference_id, :_destroy
        ],
        recipe_cuisines_attributes: [
          :id, :data_reference_id, :_destroy
        ],
        recipe_aliases_attributes: [
          :id, :alias_name, :language, :_destroy
        ]
      )
    end

    def admin_recipe_json(recipe)
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
        dietary_tags: recipe.dietary_tags.map(&:key),
        cuisines: recipe.cuisines.map(&:key),
        aliases: recipe.recipe_aliases.map(&:alias_name),
        source_url: recipe.source_url,
        admin_notes: recipe.admin_notes,
        requires_precision: recipe.requires_precision,
        precision_reason: recipe.precision_reason,
        difficulty_level: recipe.difficulty_level,
        translations_completed: recipe.translations_completed,
        last_translated_at: recipe.last_translated_at,
        created_at: recipe.created_at,
        updated_at: recipe.updated_at
      }
    end

    def admin_recipe_json_full(recipe)
      admin_recipe_json(recipe).merge(
        ingredient_groups: serialize_ingredient_groups(recipe),
        steps: serialize_recipe_steps(recipe),
        equipment: recipe.equipment.map(&:canonical_name),
        nutrition: recipe.recipe_nutrition ? serialize_nutrition(recipe.recipe_nutrition) : nil
      )
    end

    # Generic handler for all parsing endpoints
    def handle_parse(source_type)
      parser = RecipeParserService.new
      recipe_data = yield(parser)

      if recipe_data
        render_success(
          data: { recipe_data: recipe_data },
          message: "Recipe parsed successfully from #{source_type}"
        )
      else
        render_error(
          message: "Failed to parse recipe from #{source_type}",
          errors: [ "Could not extract valid recipe data" ]
        )
      end
    rescue StandardError => e
      Rails.logger.error("#{source_type.capitalize} parsing failed: #{e.class} - #{e.message}")
      Rails.logger.error(e.backtrace.join("\n")) if Rails.env.development?
      render_error(
        message: "Failed to parse recipe from #{source_type}",
        errors: [ e.message ]
      )
    end

  end
end
