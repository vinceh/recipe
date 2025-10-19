module Admin
  class AiPromptsController < BaseController
    # GET /admin/ai_prompts
    def index
      prompts = AiPrompt.all.order(created_at: :desc)

      # Filter by prompt_type if specified
      if params[:prompt_type].present?
        prompts = prompts.where(prompt_type: params[:prompt_type])
      end

      # Filter by active status
      if params[:active].present?
        prompts = prompts.where(active: params[:active] == 'true')
      end

      render_success(
        data: {
          ai_prompts: prompts.map { |p| ai_prompt_json(p) }
        }
      )
    end

    # GET /admin/ai_prompts/:id
    def show
      prompt = AiPrompt.find(params[:id])
      render_success(data: { ai_prompt: ai_prompt_json(prompt) })
    end

    # POST /admin/ai_prompts
    # AC-ADMIN-014: AI prompt CRUD
    def create
      prompt = AiPrompt.new(ai_prompt_params)

      if prompt.save
        render_success(
          data: { ai_prompt: ai_prompt_json(prompt) },
          message: 'AI prompt created successfully',
          status: :created
        )
      else
        render_error(
          message: 'Failed to create AI prompt',
          errors: prompt.errors.full_messages
        )
      end
    end

    # PUT /admin/ai_prompts/:id
    def update
      prompt = AiPrompt.find(params[:id])

      if prompt.update(ai_prompt_params)
        render_success(
          data: { ai_prompt: ai_prompt_json(prompt) },
          message: 'AI prompt updated successfully'
        )
      else
        render_error(
          message: 'Failed to update AI prompt',
          errors: prompt.errors.full_messages
        )
      end
    end

    # DELETE /admin/ai_prompts/:id
    def destroy
      prompt = AiPrompt.find(params[:id])
      prompt.destroy!

      render_success(
        data: { deleted: true },
        message: 'AI prompt deleted successfully'
      )
    end

    # POST /admin/ai_prompts/:id/activate
    def activate
      prompt = AiPrompt.find(params[:id])

      # Deactivate other prompts of the same type
      AiPrompt.where(prompt_type: prompt.prompt_type).update_all(active: false)

      # Activate this prompt
      prompt.update!(active: true)

      render_success(
        data: { ai_prompt: ai_prompt_json(prompt) },
        message: 'AI prompt activated successfully'
      )
    end

    # POST /admin/ai_prompts/:id/test
    # AC-ADMIN-015: Test AI prompt with sample data
    def test
      prompt = AiPrompt.find(params[:id])
      test_variables = params[:test_variables] || {}

      # Convert to hash and symbolize keys
      vars_hash = test_variables.is_a?(ActionController::Parameters) ? test_variables.to_unsafe_h : test_variables

      # Use the render method from the model
      test_content = prompt.render(**vars_hash.symbolize_keys)

      render_success(
        data: {
          original_content: prompt.prompt_text,
          test_content: test_content,
          variables_used: test_variables
        },
        message: 'Prompt test generated successfully'
      )
    end

    private

    def ai_prompt_params
      params.require(:ai_prompt).permit(
        :prompt_key,
        :prompt_type,
        :feature_area,
        :prompt_text,
        :description,
        :active,
        :version,
        variables: []
      )
    end

    def ai_prompt_json(prompt)
      {
        id: prompt.id,
        prompt_key: prompt.prompt_key,
        prompt_type: prompt.prompt_type,
        feature_area: prompt.feature_area,
        prompt_text: prompt.prompt_text,
        description: prompt.description,
        active: prompt.active,
        version: prompt.version,
        variables: prompt.variables,
        created_at: prompt.created_at,
        updated_at: prompt.updated_at
      }
    end
  end
end
