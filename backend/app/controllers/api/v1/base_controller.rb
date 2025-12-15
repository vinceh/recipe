module Api
  module V1
    class BaseController < ActionController::API
      include Devise::Controllers::Helpers

      before_action :configure_permitted_parameters, if: :devise_controller?
      around_action :wrap_with_locale

      # Standard JSON response format
      def render_success(data:, message: nil, status: :ok)
        render json: {
          success: true,
          message: message,
          data: data
        }, status: status
      end

      def render_error(message:, errors: nil, status: :unprocessable_entity)
        render json: {
          success: false,
          message: message,
          errors: errors
        }, status: status
      end

      # Handle common exceptions
      rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
      rescue_from ActionController::ParameterMissing, with: :parameter_missing

      private

      def configure_permitted_parameters
        devise_parameter_sanitizer.permit(:sign_up, keys: [ :email, :password, :password_confirmation ])
        devise_parameter_sanitizer.permit(:sign_in, keys: [ :email, :password ])
      end

      def record_not_found(exception)
        render_error(
          message: "Record not found",
          errors: { detail: exception.message },
          status: :not_found
        )
      end

      def parameter_missing(exception)
        render_error(
          message: "Required parameter missing",
          errors: { detail: exception.message },
          status: :bad_request
        )
      end

      def wrap_with_locale
        requested_locale = (params[:lang] || extract_locale_from_header)&.downcase
        locale = valid_locale?(requested_locale) ? requested_locale : I18n.default_locale
        I18n.with_locale(locale) { yield }
      end

      def extract_locale_from_header
        accept_language = request.headers["Accept-Language"]
        return nil unless accept_language

        # Extract first language tag, then remove quality factor (;q=...)
        # Strip whitespace and keep hyphens for locales like zh-tw, zh-cn
        first_tag = accept_language.split(",").first&.split(";")&.first&.strip&.downcase

        # Special handling for Chinese variants (zh-tw, zh-cn):
        # Try full tag first (e.g., "zh-tw") before falling back to base language ("zh")
        # This ensures Traditional/Simplified Chinese are distinguished correctly
        return first_tag if first_tag && valid_locale?(first_tag)

        # For other languages, extract base language code (e.g., ja-JP -> ja)
        first_tag&.split("-")&.first
      end

      def valid_locale?(locale)
        return false if locale.nil?

        I18n.available_locales.map(&:to_s).include?(locale.to_s)
      end
    end
  end
end
