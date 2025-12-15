module Admin
  class UnitsController < BaseController
    def index
      units = Unit.includes(:translations).order(:category, :canonical_name)

      if params[:category].present?
        units = units.where(category: params[:category])
      end

      if params[:q].present?
        search_term = "%#{params[:q].downcase}%"
        units = units.left_joins(:translations)
          .where("LOWER(units.canonical_name) LIKE ? OR LOWER(unit_translations.name) LIKE ?",
                 search_term, search_term)
          .distinct
      end

      render_success(
        data: {
          units: units.map { |u| unit_json(u) },
          categories: Unit.categories.keys
        }
      )
    end

    def show
      unit = Unit.find(params[:id])
      render_success(data: { unit: unit_json(unit, include_translations: true) })
    end

    def create
      unit = Unit.new(unit_params)

      if unit.save
        if params[:auto_translate]
          translator = UnitTranslator.new
          translator.translate_and_save(unit)
          unit.reload
        end

        render_success(
          data: { unit: unit_json(unit, include_translations: true) },
          message: 'Unit created successfully',
          status: :created
        )
      else
        render_error(
          message: 'Failed to create unit',
          errors: unit.errors.full_messages
        )
      end
    end

    def update
      unit = Unit.find(params[:id])

      if unit.update(unit_params)
        render_success(
          data: { unit: unit_json(unit, include_translations: true) },
          message: 'Unit updated successfully'
        )
      else
        render_error(
          message: 'Failed to update unit',
          errors: unit.errors.full_messages
        )
      end
    end

    def destroy
      unit = Unit.find(params[:id])

      if unit.recipe_ingredients.exists?
        render_error(
          message: 'Cannot delete unit that is in use',
          errors: ["Unit is used by #{unit.recipe_ingredients.count} recipe ingredients"]
        )
      else
        unit.destroy!
        render_success(
          data: { deleted: true },
          message: 'Unit deleted successfully'
        )
      end
    end

    def translate
      unit = Unit.find(params[:id])
      translator = UnitTranslator.new

      if translator.translate_and_save(unit)
        render_success(
          data: { unit: unit_json(unit.reload, include_translations: true) },
          message: 'Translations generated successfully'
        )
      else
        render_error(
          message: 'Failed to generate translations',
          errors: ['Translation service error']
        )
      end
    end

    private

    def unit_params
      params.require(:unit).permit(:canonical_name, :category)
    end

    def unit_json(unit, include_translations: false)
      json = {
        id: unit.id,
        canonical_name: unit.canonical_name,
        category: unit.category,
        name: unit.name,
        usage_count: unit.recipe_ingredients.count,
        created_at: unit.created_at,
        updated_at: unit.updated_at
      }

      if include_translations
        json[:translations] = {}
        %i[en ja ko zh-tw zh-cn es fr].each do |locale|
          I18n.with_locale(locale) do
            json[:translations][locale] = unit.name
          end
        end
      end

      json
    end
  end
end
