module Api
  module V1
    class DataReferencesController < BaseController
      # GET /api/v1/data_references
      # Get all reference data (dietary tags, dish types, cuisines, etc.)
      def index
        data = {
          dietary_tags: DataReference.dietary_tags.active.map { |ref| { id: ref.id, key: ref.key, display_name: I18n.t("data_references.dietary_tags.#{ref.key}", default: ref.key) } },
          cuisines: DataReference.cuisines.active.map { |ref| { id: ref.id, key: ref.key, display_name: I18n.t("data_references.cuisines.#{ref.key}", default: ref.key) } }
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
