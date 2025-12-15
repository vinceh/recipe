module Api
  module V1
    class IngredientsController < BaseController
      def search
        query = params[:q].to_s.strip

        if query.blank?
          return render_success(data: { exact_match: nil, suggestions: [] })
        end

        result = IngredientSearchService.find_or_suggest(query)

        render_success(data: {
          exact_match: result[:exact_match] ? serialize_ingredient(result[:exact_match]) : nil,
          suggestions: result[:suggestions].map { |i| serialize_ingredient(i) }
        })
      end

      private

      def serialize_ingredient(ingredient)
        {
          id: ingredient.id,
          name: ingredient.canonical_name,
          category: ingredient.category,
          nutrition: serialize_nutrition(ingredient.nutrition)
        }
      end

      def serialize_nutrition(nutrition)
        return nil unless nutrition

        {
          calories: nutrition.calories,
          protein_g: nutrition.protein_g,
          carbs_g: nutrition.carbs_g,
          fat_g: nutrition.fat_g
        }
      end
    end
  end
end
