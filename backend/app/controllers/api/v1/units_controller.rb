module Api
  module V1
    class UnitsController < BaseController
      SUPPORTED_LOCALES = %i[en ja ko zh-tw zh-cn es fr].freeze

      def index
        units = Unit.includes(:translations).order(:category, :canonical_name)

        render_success(data: {
          units: units.map { |u| unit_json(u) },
          categories: Unit.categories.keys
        })
      end

      private

      def unit_json(unit)
        {
          id: unit.id,
          canonical_name: unit.canonical_name,
          category: unit.category,
          translations: build_translations(unit)
        }
      end

      def build_translations(unit)
        translations = {}
        SUPPORTED_LOCALES.each do |locale|
          I18n.with_locale(locale) do
            translations[locale] = unit.name
          end
        end
        translations
      end
    end
  end
end
