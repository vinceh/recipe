# I18n Configuration
# This initializer sets up internationalization for the Recipe App

# Configure fallback behavior
I18n::Backend::Simple.include(I18n::Backend::Fallbacks)

# Log missing translations in development
if Rails.env.development?
  I18n.exception_handler = lambda do |exception, locale, key, options|
    if exception.is_a?(I18n::MissingTranslation)
      Rails.logger.warn "Missing translation: #{key} (locale: #{locale})"
      "[missing: #{key}]"
    else
      raise exception
    end
  end
end
