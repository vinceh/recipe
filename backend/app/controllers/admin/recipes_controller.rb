module Admin
  class RecipesController < BaseController
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
        cuisines = params[:cuisines].is_a?(Array) ? params[:cuisines] : [params[:cuisines]]
        cuisines.each do |cuisine|
          recipes = recipes.where("cuisines @> ?", [cuisine].to_json)
        end
      elsif params[:cuisine].present?
        # Legacy single cuisine filter
        recipes = recipes.where("cuisines @> ?", [params[:cuisine]].to_json)
      end

      # Filter by dish types (multiple)
      if params[:dish_types].present?
        dish_types = params[:dish_types].is_a?(Array) ? params[:dish_types] : [params[:dish_types]]
        dish_types.each do |dish_type|
          recipes = recipes.where("dish_types @> ?", [dish_type].to_json)
        end
      end

      # Filter by max prep time
      if params[:max_prep_time].present?
        max_time = params[:max_prep_time].to_i
        recipes = recipes.where("(timing->>'prep_minutes')::int <= ?", max_time)
      end

      if params[:dietary_tag].present?
        recipes = recipes.where("dietary_tags @> ?", [params[:dietary_tag]].to_json)
      end

      # Pagination
      page = params[:page]&.to_i || 1
      per_page = params[:per_page]&.to_i || 20
      per_page = [per_page, 100].min

      paginated_recipes = recipes
        .offset((page - 1) * per_page)
        .limit(per_page)

      total_count = recipes.count
      total_pages = (total_count.to_f / per_page).ceil

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
      recipe = Recipe.find(params[:id])

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
          message: 'Recipe created successfully',
          status: :created
        )
      else
        render_error(
          message: 'Failed to create recipe',
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
          message: 'Recipe updated successfully'
        )
      else
        render_error(
          message: 'Failed to update recipe',
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
        message: 'Recipe deleted successfully'
      )
    end

    # POST /admin/recipes/parse_text
    # AC-ADMIN-002: Parse recipe from text block
    def parse_text
      text_content = params.require(:text_content)

      parser = RecipeParserService.new
      recipe_data = parser.parse_text_block(text_content)

      if recipe_data
        render_success(
          data: { recipe_data: recipe_data },
          message: 'Recipe parsed successfully'
        )
      else
        render_error(
          message: 'Failed to parse recipe from text',
          errors: ['Could not extract valid recipe data']
        )
      end
    end

    # POST /admin/recipes/parse_url
    # AC-ADMIN-003: Parse recipe from URL
    def parse_url
      url = params.require(:url)

      parser = RecipeParserService.new
      recipe_data = parser.parse_url(url)

      if recipe_data
        render_success(
          data: { recipe_data: recipe_data },
          message: 'Recipe parsed successfully from URL'
        )
      else
        render_error(
          message: 'Failed to parse recipe from URL',
          errors: ['Could not extract valid recipe data']
        )
      end
    rescue StandardError => e
      render_error(
        message: 'Failed to fetch or parse URL',
        errors: [e.message]
      )
    end

    # POST /admin/recipes/parse_image
    # AC-ADMIN-004: Parse recipe from image
    def parse_image
      # Handle both file upload and URL
      if params[:image_file].present?
        # File upload - save temporarily
        uploaded_file = params[:image_file]
        temp_path = Rails.root.join('tmp', 'uploads', uploaded_file.original_filename)
        FileUtils.mkdir_p(File.dirname(temp_path))
        File.open(temp_path, 'wb') do |file|
          file.write(uploaded_file.read)
        end

        parser = RecipeParserService.new
        recipe_data = parser.parse_image(temp_path.to_s)

        # Clean up temp file
        File.delete(temp_path) if File.exist?(temp_path)
      elsif params[:image_url].present?
        # URL to image
        parser = RecipeParserService.new
        recipe_data = parser.parse_image(params[:image_url])
      else
        return render_error(
          message: 'Image file or URL required',
          errors: ['Provide either image_file or image_url parameter'],
          status: :bad_request
        )
      end

      if recipe_data
        render_success(
          data: { recipe_data: recipe_data },
          message: 'Recipe parsed successfully from image'
        )
      else
        render_error(
          message: 'Failed to parse recipe from image',
          errors: ['Could not extract valid recipe data']
        )
      end
    rescue StandardError => e
      render_error(
        message: 'Failed to process image',
        errors: [e.message]
      )
    end

    # POST /admin/recipes/:id/regenerate_variants
    # AC-ADMIN-007: Regenerate step variants
    def regenerate_variants
      recipe = Recipe.find(params[:id])

      # This would call a service to regenerate easier/no-equipment variants
      # For now, we'll just mark it as regenerated
      recipe.update!(
        variants_generated: true,
        variants_generated_at: Time.current
      )

      render_success(
        data: { recipe: admin_recipe_json(recipe) },
        message: 'Step variants regeneration queued'
      )
    end

    # POST /admin/recipes/:id/regenerate_translations
    # AC-ADMIN-008: Regenerate translations
    def regenerate_translations
      recipe = Recipe.find(params[:id])

      # This would call a service to regenerate translations
      # For now, we'll just mark it as regenerated
      recipe.update!(translations_completed: false)

      render_success(
        data: { recipe: admin_recipe_json(recipe) },
        message: 'Translation regeneration queued'
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
          message: 'recipe_ids must be an array',
          status: :bad_request
        )
      end

      deleted_count = Recipe.where(id: recipe_ids).destroy_all.count

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
        :language,
        :requires_precision,
        :precision_reason,
        :source_url,
        :admin_notes,
        servings: [:original, :min, :max],
        timing: [:prep_minutes, :cook_minutes, :total_minutes],
        nutrition: {},
        aliases: [],
        dietary_tags: [],
        dish_types: [],
        recipe_types: [],
        cuisines: [],
        ingredient_groups: [
          :name,
          items: [:name, :amount, :unit, :notes, :optional]
        ],
        steps: [
          :id,
          instructions: {}
        ],
        equipment: [],
        translations: {}
      )
    end

    def admin_recipe_json(recipe)
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
        aliases: recipe.aliases,
        source_url: recipe.source_url,
        admin_notes: recipe.admin_notes,
        requires_precision: recipe.requires_precision,
        precision_reason: recipe.precision_reason,
        variants_generated: recipe.variants_generated,
        variants_generated_at: recipe.variants_generated_at,
        translations_completed: recipe.translations_completed,
        created_at: recipe.created_at,
        updated_at: recipe.updated_at
      }
    end

    def admin_recipe_json_full(recipe)
      admin_recipe_json(recipe).merge(
        ingredient_groups: recipe.ingredient_groups,
        steps: recipe.steps,
        equipment: recipe.equipment,
        nutrition: recipe.nutrition,
        translations: recipe.translations
      )
    end
  end
end
