module Api
  module V1
    class DataReferencesController < BaseController
      # GET /api/v1/data_references
      # Get all reference data (dietary tags, dish types, cuisines, etc.)
      def index
        data = {
          dietary_tags: DataReference.dietary_tags.active.pluck(:key, :display_name).map { |k, d| { key: k, display_name: d } },
          dish_types: DataReference.dish_types.active.pluck(:key, :display_name).map { |k, d| { key: k, display_name: d } },
          recipe_types: DataReference.recipe_types.active.pluck(:key, :display_name).map { |k, d| { key: k, display_name: d } },
          cuisines: DataReference.cuisines.active.pluck(:key, :display_name).map { |k, d| { key: k, display_name: d } }
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
