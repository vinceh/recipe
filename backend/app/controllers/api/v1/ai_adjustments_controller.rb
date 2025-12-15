module Api
  module V1
    class AiAdjustmentsController < BaseController
      def adjust_recipe
        recipe_json = params.require(:recipe).permit!.to_h
        user_prompt = params.require(:prompt)

        ai_service = AiService.new
        adjusted_recipe = ai_service.adjust_recipe(
          recipe_json: recipe_json,
          user_prompt: user_prompt
        )

        render_success(data: { recipe: adjusted_recipe })
      rescue StandardError => e
        Rails.logger.error("Recipe adjustment failed: #{e.message}")
        render_error(
          message: "Failed to adjust recipe: #{e.message}",
          status: :unprocessable_entity
        )
      end
    end
  end
end
