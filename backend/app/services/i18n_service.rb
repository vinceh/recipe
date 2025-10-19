# I18nService
# Manages locale detection and setting for the application
# Supports Accept-Language header parsing and user preferences

class I18nService
  AVAILABLE_LOCALES = %i[en ja ko zh-tw zh-cn es fr].freeze
  DEFAULT_LOCALE = :en

  # Set locale based on multiple sources (priority order):
  # 1. User preference (if authenticated)
  # 2. Accept-Language header
  # 3. Default locale
  def self.set_locale(user: nil, accept_language: nil)
    locale = determine_locale(user: user, accept_language: accept_language)
    I18n.locale = locale
    locale
  end

  # Determine locale from user preference or Accept-Language header
  def self.determine_locale(user: nil, accept_language: nil)
    # 1. Check user preference
    if user&.preferred_language.present?
      locale = user.preferred_language.to_sym
      return locale if AVAILABLE_LOCALES.include?(locale)
    end

    # 2. Parse Accept-Language header
    if accept_language.present?
      locale = detect_locale_from_header(accept_language)
      return locale if locale
    end

    # 3. Fall back to default
    DEFAULT_LOCALE
  end

  # Parse Accept-Language header and find best match
  # Header format: "en-US,en;q=0.9,ja;q=0.8"
  def self.detect_locale_from_header(header)
    return DEFAULT_LOCALE if header.blank?

    # Parse language preferences from header
    languages = parse_accept_language(header)

    # Find first matching available locale
    languages.each do |lang_code|
      # Normalize language code (e.g., "en-US" -> :en, "zh-TW" -> :"zh-tw")
      normalized = normalize_language_code(lang_code)
      return normalized if AVAILABLE_LOCALES.include?(normalized)
    end

    DEFAULT_LOCALE
  end

  private

  # Parse Accept-Language header into sorted array of language codes
  # Returns languages sorted by quality value (q parameter)
  def self.parse_accept_language(header)
    languages = header.split(',').map do |lang|
      parts = lang.strip.split(';')
      code = parts[0].strip
      quality = parts[1]&.split('=')&.last&.to_f || 1.0
      { code: code, quality: quality }
    end

    # Sort by quality (descending) and extract codes
    languages.sort_by { |l| -l[:quality] }.map { |l| l[:code] }
  end

  # Normalize language code to match available locales
  # Examples:
  #   "en" -> :en
  #   "en-US" -> :en
  #   "ja-JP" -> :ja
  #   "zh-TW" -> :"zh-tw"
  #   "zh-CN" -> :"zh-cn"
  def self.normalize_language_code(code)
    # Extract primary language tag
    primary = code.split('-').first.downcase

    # Handle Chinese variants specially
    if primary == 'zh'
      script_or_region = code.split('-')[1]&.downcase
      return :'zh-tw' if script_or_region&.match?(/tw|hant/)
      return :'zh-cn' if script_or_region&.match?(/cn|hans/)
      return :'zh-tw' # Default to Traditional Chinese
    end

    primary.to_sym
  end
end
