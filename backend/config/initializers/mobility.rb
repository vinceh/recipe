Mobility.configure do
  # PLUGINS
  plugins do
    # Backend
    #
    # Use Table backend for translations stored in dedicated translation tables
    #
    backend :table, association_name: :translations

    # ActiveRecord
    #
    # Defines ActiveRecord as ORM, and enables ActiveRecord-specific plugins.
    active_record

    # Accessors
    #
    # Define reader and writer methods for translated attributes.
    #
    reader
    writer

    # Backend Reader
    #
    # Defines reader to access the backend for any attribute.
    #
    backend_reader

    # Query
    #
    # Enables i18n scope for querying translated attributes.
    #
    query

    # Cache
    #
    # Enable caching reads and writes.
    #
    cache

    # Dirty
    #
    # Track changes to translations.
    #
    dirty

    # Presence
    #
    # Convert blank strings to nil on reads and writes.
    #
    presence

    # Fallbacks
    #
    # Enable fallback chain for missing translations.
    # Chain: ja→en, ko→en, zh-tw→zh-cn→en, zh-cn→zh-tw→en, es→en, fr→en
    #
    fallbacks(
      ja: :en,
      ko: :en,
      "zh-tw": [:"zh-cn", :en],
      "zh-cn": [:"zh-tw", :en],
      es: :en,
      fr: :en
    )

    # Locale Accessors
    #
    # Define locale-specific accessor methods for supported languages.
    # This enables methods like +name_en+, +name_ja+, etc.
    #
    locale_accessors [:en, :ja, :ko, :"zh-tw", :"zh-cn", :es, :fr]
  end
end
