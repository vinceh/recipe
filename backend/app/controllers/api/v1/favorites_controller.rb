module Api
  module V1
    class FavoritesController < BaseController
      include RecipeSerializer
      before_action :authenticate_user!

      # POST /api/v1/recipes/:id/favorite
      # Add recipe to user's favorites
      def create
        recipe = Recipe.find(params[:id])

        favorite = current_user.user_favorites.find_or_initialize_by(recipe: recipe)

        if favorite.new_record?
          favorite.save!
          render_success(
            data: { favorited: true },
            message: 'Recipe added to favorites',
            status: :created
          )
        else
          render_success(
            data: { favorited: true },
            message: 'Recipe already in favorites'
          )
        end
      end

      # DELETE /api/v1/recipes/:id/favorite
      # Remove recipe from user's favorites
      def destroy
        recipe = Recipe.find(params[:id])
        favorite = current_user.user_favorites.find_by(recipe: recipe)

        if favorite
          favorite.destroy!
          render_success(
            data: { favorited: false },
            message: 'Recipe removed from favorites'
          )
        else
          render_error(
            message: 'Recipe not in favorites',
            status: :not_found
          )
        end
      end

      # GET /api/v1/users/me/favorites
      # Get current user's favorite recipes
      def index
        favorites = current_user.user_favorites
          .includes(recipe: [:dietary_tags, :cuisines, { card_image_attachment: :blob }, { detail_image_attachment: :blob }])
          .order(created_at: :desc)

        # Pagination
        page = params[:page]&.to_i || 1
        per_page = params[:per_page]&.to_i || 20
        per_page = [per_page, 100].min

        paginated_favorites = favorites
          .offset((page - 1) * per_page)
          .limit(per_page)

        total_count = favorites.count
        total_pages = (total_count.to_f / per_page).ceil

        render_success(
          data: {
            favorites: paginated_favorites.map do |fav|
              recipe_list_json(fav.recipe).merge(
                favorited_at: fav.created_at
              )
            end,
            pagination: {
              current_page: page,
              per_page: per_page,
              total_count: total_count,
              total_pages: total_pages
            }
          }
        )
      end

      private

      def recipe_list_json(recipe)
        {
          id: recipe.id,
          name: recipe.name,
          description: recipe.description,
          language: recipe.source_language,
          image_url: recipe.card_image.attached? ? rails_blob_url(recipe.card_image, only_path: false) : nil,
          card_image_url: recipe.card_image.attached? ? rails_blob_url(recipe.card_image, only_path: false) : nil,
          detail_image_url: recipe.detail_image.attached? ? rails_blob_url(recipe.detail_image, only_path: false) : nil,
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
          tags: recipe.tags,
          source_url: recipe.source_url,
          difficulty_level: recipe.difficulty_level,
          translations_completed: recipe.translations_completed,
          last_translated_at: recipe.last_translated_at,
          created_at: recipe.created_at,
          updated_at: recipe.updated_at,
          favorite: true
        }
      end
    end
  end
end
