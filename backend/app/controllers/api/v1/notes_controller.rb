module Api
  module V1
    class NotesController < BaseController
      before_action :authenticate_user!
      before_action :set_note, only: [:update, :destroy]

      # POST /api/v1/recipes/:recipe_id/notes
      # Create a note for a recipe
      def create
        recipe = Recipe.find(params[:recipe_id])

        note = current_user.user_recipe_notes.build(
          recipe: recipe,
          note_type: params.require(:note_type),
          note_target_id: params[:note_target_id],
          note_text: params.require(:note_text)
        )

        if note.save
          render_success(
            data: { note: note_json(note) },
            message: 'Note created successfully',
            status: :created
          )
        else
          render_error(
            message: 'Failed to create note',
            errors: note.errors.full_messages
          )
        end
      end

      # PUT /api/v1/notes/:id
      # Update a note
      def update
        if @note.update(note_text: params.require(:note_text))
          render_success(
            data: { note: note_json(@note) },
            message: 'Note updated successfully'
          )
        else
          render_error(
            message: 'Failed to update note',
            errors: @note.errors.full_messages
          )
        end
      end

      # DELETE /api/v1/notes/:id
      # Delete a note
      def destroy
        @note.destroy!
        render_success(
          data: { deleted: true },
          message: 'Note deleted successfully'
        )
      end

      # GET /api/v1/recipes/:recipe_id/notes
      # Get all notes for a recipe (for current user)
      def index
        recipe = Recipe.find(params[:recipe_id])
        notes = current_user.user_recipe_notes
          .where(recipe: recipe)
          .order(created_at: :desc)

        render_success(
          data: {
            notes: notes.map { |note| note_json(note) }
          }
        )
      end

      private

      def set_note
        @note = current_user.user_recipe_notes.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render_error(
          message: 'Note not found or you do not have permission to modify it',
          status: :not_found
        )
      end

      def note_json(note)
        {
          id: note.id,
          recipe_id: note.recipe_id,
          note_type: note.note_type,
          note_target_id: note.note_target_id,
          note_text: note.note_text,
          created_at: note.created_at,
          updated_at: note.updated_at
        }
      end
    end
  end
end
