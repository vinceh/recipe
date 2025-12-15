module Api
  module V1
    module Auth
      class MeController < Api::V1::BaseController
        before_action :authenticate_user!

        def show
          render json: {
            success: true,
            data: {
              user: {
                id: current_user.id,
                email: current_user.email,
                role: current_user.role,
                preferred_language: current_user.preferred_language
              }
            }
          }, status: :ok
        end
      end
    end
  end
end
