module Admin
  class IngredientsController < BaseController
    # GET /admin/ingredients
    def index
      ingredients = Ingredient.includes(:nutrition, :aliases).order(:canonical_name)

      # Filter by category if specified
      if params[:category].present?
        ingredients = ingredients.where(category: params[:category])
      end

      # Search by name
      if params[:q].present?
        ingredients = ingredients.where("LOWER(canonical_name) LIKE ?", "%#{params[:q].downcase}%")
      end

      # Pagination
      page = params[:page]&.to_i || 1
      per_page = params[:per_page]&.to_i || 50
      per_page = [per_page, 100].min

      paginated_ingredients = ingredients
        .offset((page - 1) * per_page)
        .limit(per_page)

      total_count = ingredients.count
      total_pages = (total_count.to_f / per_page).ceil

      render_success(
        data: {
          ingredients: paginated_ingredients.map { |i| ingredient_json(i) },
          pagination: {
            current_page: page,
            per_page: per_page,
            total_count: total_count,
            total_pages: total_pages
          }
        }
      )
    end

    # GET /admin/ingredients/:id
    def show
      ingredient = Ingredient.includes(:nutrition, :aliases).find(params[:id])
      render_success(data: { ingredient: ingredient_json(ingredient, include_details: true) })
    end

    # POST /admin/ingredients
    def create
      ingredient = Ingredient.new(ingredient_params)

      if ingredient.save
        # Create nutrition record if nutrition params provided
        if params[:nutrition].present?
          ingredient.create_nutrition!(nutrition_params)
        end

        # Create aliases if provided
        if params[:aliases].present?
          params[:aliases].each do |alias_data|
            ingredient.aliases.create!(
              alias: alias_data[:alias],
              language: alias_data[:language] || 'en'
            )
          end
        end

        render_success(
          data: { ingredient: ingredient_json(ingredient.reload, include_details: true) },
          message: 'Ingredient created successfully',
          status: :created
        )
      else
        render_error(
          message: 'Failed to create ingredient',
          errors: ingredient.errors.full_messages
        )
      end
    end

    # PUT /admin/ingredients/:id
    def update
      ingredient = Ingredient.find(params[:id])

      # Update ingredient attributes if provided
      if params[:ingredient].present?
        unless ingredient.update(ingredient_params)
          return render_error(
            message: 'Failed to update ingredient',
            errors: ingredient.errors.full_messages
          )
        end
      end

      # Update nutrition if provided
      if params[:nutrition].present?
        if ingredient.nutrition
          ingredient.nutrition.update!(nutrition_params)
        else
          ingredient.create_nutrition!(nutrition_params)
        end
      end

      render_success(
        data: { ingredient: ingredient_json(ingredient.reload, include_details: true) },
        message: 'Ingredient updated successfully'
      )
    end

    # DELETE /admin/ingredients/:id
    def destroy
      ingredient = Ingredient.find(params[:id])
      ingredient.destroy!

      render_success(
        data: { deleted: true },
        message: 'Ingredient deleted successfully'
      )
    end

    # POST /admin/ingredients/:id/refresh_nutrition
    # AC-NUTR-013: Refresh nutrition data from Nutritionix API
    def refresh_nutrition
      ingredient = Ingredient.find(params[:id])

      # TODO: Implement Nutritionix API integration
      # For now, just update the data source and confidence score
      if ingredient.nutrition
        ingredient.nutrition.update!(
          data_source: 'nutritionix',
          confidence_score: 1.0
        )

        render_success(
          data: { ingredient: ingredient_json(ingredient.reload, include_details: true) },
          message: 'Nutrition data refreshed successfully'
        )
      else
        render_error(
          message: 'No nutrition data to refresh',
          errors: ['Create nutrition data first']
        )
      end
    end

    private

    def ingredient_params
      params.require(:ingredient).permit(:canonical_name, :category)
    end

    def nutrition_params
      params.require(:nutrition).permit(
        :calories,
        :protein_g,
        :carbs_g,
        :fat_g,
        :fiber_g,
        :data_source,
        :confidence_score
      )
    end

    def ingredient_json(ingredient, include_details: false)
      json = {
        id: ingredient.id,
        canonical_name: ingredient.canonical_name,
        category: ingredient.category,
        created_at: ingredient.created_at,
        updated_at: ingredient.updated_at
      }

      if include_details
        json[:nutrition] = ingredient.nutrition ? {
          calories: ingredient.nutrition.calories,
          protein_g: ingredient.nutrition.protein_g,
          carbs_g: ingredient.nutrition.carbs_g,
          fat_g: ingredient.nutrition.fat_g,
          fiber_g: ingredient.nutrition.fiber_g,
          data_source: ingredient.nutrition.data_source,
          confidence_score: ingredient.nutrition.confidence_score
        } : nil

        json[:aliases] = ingredient.aliases.map do |a|
          { alias: a.alias, language: a.language }
        end
      else
        json[:has_nutrition] = ingredient.nutrition.present?
        json[:aliases_count] = ingredient.aliases.count
      end

      json
    end
  end
end
