module Admin
  class DataReferencesController < BaseController
    # GET /admin/data_references
    def index
      data_refs = DataReference.all.order(reference_type: :asc, key: :asc)

      # Filter by type if specified
      if params[:reference_type].present?
        data_refs = data_refs.where(reference_type: params[:reference_type])
      end

      # Filter by active status
      if params[:active].present?
        data_refs = data_refs.where(active: params[:active] == 'true')
      end

      render_success(
        data: {
          data_references: data_refs.map { |dr| data_reference_json(dr) }
        }
      )
    end

    # GET /admin/data_references/:id
    def show
      data_ref = DataReference.find(params[:id])
      render_success(data: { data_reference: data_reference_json(data_ref) })
    end

    # POST /admin/data_references
    def create
      data_ref = DataReference.new(data_reference_params)

      if data_ref.save
        render_success(
          data: { data_reference: data_reference_json(data_ref) },
          message: 'Data reference created successfully',
          status: :created
        )
      else
        render_error(
          message: 'Failed to create data reference',
          errors: data_ref.errors.full_messages
        )
      end
    end

    # PUT /admin/data_references/:id
    # AC-ADMIN-012: Dietary tag editing with cascade update
    def update
      data_ref = DataReference.find(params[:id])

      if data_ref.update(data_reference_params)
        render_success(
          data: { data_reference: data_reference_json(data_ref) },
          message: 'Data reference updated successfully'
        )
      else
        render_error(
          message: 'Failed to update data reference',
          errors: data_ref.errors.full_messages
        )
      end
    end

    # DELETE /admin/data_references/:id
    def destroy
      data_ref = DataReference.find(params[:id])
      data_ref.destroy!

      render_success(
        data: { deleted: true },
        message: 'Data reference deleted successfully'
      )
    end

    # POST /admin/data_references/:id/deactivate
    # AC-ADMIN-013: Tag deactivation
    def deactivate
      data_ref = DataReference.find(params[:id])
      data_ref.update!(active: false)

      render_success(
        data: { data_reference: data_reference_json(data_ref) },
        message: 'Data reference deactivated successfully'
      )
    end

    # POST /admin/data_references/:id/activate
    def activate
      data_ref = DataReference.find(params[:id])
      data_ref.update!(active: true)

      render_success(
        data: { data_reference: data_reference_json(data_ref) },
        message: 'Data reference activated successfully'
      )
    end

    private

    def data_reference_params
      params.require(:data_reference).permit(
        :reference_type,
        :key,
        :display_name,
        :active,
        :sort_order,
        metadata: {}
      )
    end

    def data_reference_json(data_ref)
      {
        id: data_ref.id,
        reference_type: data_ref.reference_type,
        key: data_ref.key,
        display_name: data_ref.display_name,
        active: data_ref.active,
        sort_order: data_ref.sort_order,
        metadata: data_ref.metadata,
        created_at: data_ref.created_at,
        updated_at: data_ref.updated_at
      }
    end
  end
end
