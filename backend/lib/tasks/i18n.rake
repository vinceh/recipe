# Internationalization (i18n) rake tasks
namespace :i18n do
  desc 'Check for missing translation keys across all locales'
  task missing_keys: :environment do
    require 'yaml'

    default_locale = I18n.default_locale
    available_locales = I18n.available_locales - [default_locale]

    puts "=" * 80
    puts "I18n Missing Translation Keys Report"
    puts "=" * 80
    puts "Default locale: #{default_locale}"
    puts "Checking locales: #{available_locales.join(', ')}"
    puts "=" * 80
    puts

    # Load default locale translations
    default_file = Rails.root.join("config/locales/#{default_locale}.yml")
    default_translations = YAML.load_file(default_file)[default_locale.to_s]
    default_keys = flatten_hash(default_translations)

    total_missing = 0
    locale_results = {}

    available_locales.each do |locale|
      locale_file = Rails.root.join("config/locales/#{locale}.yml")
      
      unless File.exist?(locale_file)
        puts "⚠️  WARNING: Locale file not found for #{locale}"
        next
      end

      locale_translations = YAML.load_file(locale_file)[locale.to_s]
      locale_keys = flatten_hash(locale_translations)

      missing_keys = default_keys.keys - locale_keys.keys
      
      if missing_keys.any?
        locale_results[locale] = missing_keys
        total_missing += missing_keys.size
      end
    end

    if locale_results.empty?
      puts "✅ No missing translation keys found!"
      puts
    else
      locale_results.each do |locale, missing_keys|
        puts "#{locale.to_s.upcase} - Missing #{missing_keys.size} keys:"
        puts "-" * 80
        missing_keys.sort.each do |key|
          puts "  - #{key}"
        end
        puts
      end

      puts "=" * 80
      puts "Total missing keys: #{total_missing}"
      puts "=" * 80
    end
  end

  desc 'Report translation coverage percentage for each locale'
  task coverage: :environment do
    require 'yaml'

    default_locale = I18n.default_locale
    available_locales = I18n.available_locales - [default_locale]

    puts "=" * 80
    puts "I18n Translation Coverage Report"
    puts "=" * 80
    puts "Default locale: #{default_locale}"
    puts "=" * 80
    puts

    # Load default locale translations
    default_file = Rails.root.join("config/locales/#{default_locale}.yml")
    default_translations = YAML.load_file(default_file)[default_locale.to_s]
    default_keys = flatten_hash(default_translations)
    total_keys = default_keys.size

    puts "Total translation keys in #{default_locale}: #{total_keys}"
    puts
    puts "Coverage by locale:"
    puts "-" * 80

    coverage_data = []

    available_locales.each do |locale|
      locale_file = Rails.root.join("config/locales/#{locale}.yml")
      
      unless File.exist?(locale_file)
        coverage_data << { locale: locale, coverage: 0, translated: 0, total: total_keys }
        next
      end

      locale_translations = YAML.load_file(locale_file)[locale.to_s]
      locale_keys = flatten_hash(locale_translations)
      
      # Count non-TODO translations
      non_todo_keys = locale_keys.reject { |k, v| v.to_s.include?('TODO') || v.to_s.include?('[Translation needed]') }
      translated_count = non_todo_keys.size
      coverage_percent = (translated_count.to_f / total_keys * 100).round(2)

      coverage_data << {
        locale: locale,
        coverage: coverage_percent,
        translated: translated_count,
        total: total_keys
      }
    end

    # Sort by coverage percentage descending
    coverage_data.sort_by { |d| -d[:coverage] }.each do |data|
      bar_length = (data[:coverage] / 2).round
      bar = "█" * bar_length + "░" * (50 - bar_length)
      
      status = if data[:coverage] >= 90
                 "✅"
               elsif data[:coverage] >= 50
                 "⚠️ "
               else
                 "❌"
               end

      puts "#{status} #{data[:locale].to_s.upcase.ljust(8)} │ #{bar} │ #{data[:coverage].to_s.rjust(6)}% (#{data[:translated]}/#{data[:total]})"
    end

    puts "-" * 80
    avg_coverage = (coverage_data.sum { |d| d[:coverage] } / coverage_data.size).round(2)
    puts "Average coverage: #{avg_coverage}%"
    puts "=" * 80
  end

  desc 'Export untranslated keys for a specific locale'
  task :export_missing, [:locale] => :environment do |t, args|
    require 'yaml'

    locale = args[:locale]&.to_sym
    
    unless locale
      puts "Error: Please specify a locale (e.g., rake i18n:export_missing[ja])"
      exit 1
    end

    unless I18n.available_locales.include?(locale)
      puts "Error: Locale '#{locale}' is not available. Available: #{I18n.available_locales.join(', ')}"
      exit 1
    end

    default_locale = I18n.default_locale
    default_file = Rails.root.join("config/locales/#{default_locale}.yml")
    default_translations = YAML.load_file(default_file)[default_locale.to_s]
    default_keys = flatten_hash(default_translations)

    locale_file = Rails.root.join("config/locales/#{locale}.yml")
    locale_translations = File.exist?(locale_file) ? YAML.load_file(locale_file)[locale.to_s] : {}
    locale_keys = flatten_hash(locale_translations)

    missing_keys = default_keys.keys - locale_keys.keys

    if missing_keys.empty?
      puts "✅ No missing keys for locale '#{locale}'"
    else
      output_file = Rails.root.join("tmp/missing_translations_#{locale}.yml")
      FileUtils.mkdir_p(Rails.root.join("tmp"))

      missing_data = {}
      missing_keys.each do |key|
        missing_data[key] = default_keys[key]
      end

      File.write(output_file, missing_data.to_yaml)
      puts "✅ Exported #{missing_keys.size} missing keys to: #{output_file}"
      puts
      puts "Missing keys:"
      missing_keys.sort.each { |k| puts "  - #{k}" }
    end
  end

  # Helper method to flatten nested hash into dot notation
  def flatten_hash(hash, prefix = '')
    result = {}
    hash.each do |key, value|
      new_key = prefix.empty? ? key.to_s : "#{prefix}.#{key}"
      if value.is_a?(Hash)
        result.merge!(flatten_hash(value, new_key))
      else
        result[new_key] = value
      end
    end
    result
  end
end
