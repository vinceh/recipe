module Api
  module V1
    class DataReferencesController < BaseController
      # GET /api/v1/data_references
      # Get all reference data (dietary tags, dish types, cuisines, etc.)
      def index
        data = {
          dietary_tags: DataReference.dietary_tags.active.map { |ref| { id: ref.id, key: ref.key, display_name: ref.display_name } },
          dish_types: DataReference.dish_types.active.map { |ref| { id: ref.id, key: ref.key, display_name: ref.display_name } },
          recipe_types: DataReference.recipe_types.active.map { |ref| { id: ref.id, key: ref.key, display_name: ref.display_name } },
          cuisines: DataReference.cuisines.active.map { |ref| { id: ref.id, key: ref.key, display_name: ref.display_name } }
        }

        # Filter by category if requested
        if params[:category].present?
          category = params[:category].to_sym
          if data.key?(category)
            render_success(data: { category => data[category] })
          else
            render_error(
              message: "Invalid category. Valid categories: #{data.keys.join(', ')}",
              status: :bad_request
            )
          end
        else
          render_success(data: data)
        end
      end
    end
  end
end
