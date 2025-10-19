class ApplicationController < ActionController::API
  before_action :set_locale

  private

  # Set locale from user preference or Accept-Language header
  def set_locale
    user = current_user if respond_to?(:current_user)
    accept_language = request.headers['Accept-Language']

    I18nService.set_locale(user: user, accept_language: accept_language)
  end
end
