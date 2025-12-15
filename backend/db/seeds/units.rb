# Seed standard units with translations

puts "📏 Seeding units..."

load File.join(File.dirname(__FILE__), "04_units_data.rb")

LOCALES = [:ja, :ko, :"zh-tw", :"zh-cn", :es, :fr].freeze

UNITS_DATA.each do |canonical_name, data|
  unit = Unit.find_or_create_by!(canonical_name: canonical_name) do |u|
    u.category = data[:category]
  end

  # Set English name (canonical)
  I18n.with_locale(:en) do
    unit.name = data[:translations][:en]
    unit.save!
  end

  # Set translations for other locales
  LOCALES.each do |locale|
    trans_key = LOCALE_MAP[locale] || locale
    translated_name = data[:translations][trans_key]

    next unless translated_name

    I18n.with_locale(locale) do
      unit.name = translated_name
      unit.save!
    end
  end
end

puts "✅ Created #{Unit.count} units with translations"

# Print summary by category
Unit.categories.keys.each do |category|
  count = Unit.where(category: category).count
  puts "   • #{category.capitalize}: #{count} units"
end
