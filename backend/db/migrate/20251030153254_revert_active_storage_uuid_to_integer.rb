class RevertActiveStorageUuidToInteger < ActiveRecord::Migration[8.0]
  def change
    # Drop the unique index that depends on record_id
    remove_index :active_storage_attachments,
                 name: :index_active_storage_attachments_uniqueness

    # Clear all attachments (convert UUIDs to NULL when converting back to bigint)
    execute "TRUNCATE active_storage_attachments"

    # Change record_id column back from uuid to bigint
    execute "ALTER TABLE active_storage_attachments ALTER COLUMN record_id TYPE bigint USING NULL"

    # Recreate the unique index
    add_index :active_storage_attachments,
              [ :record_type, :record_id, :name, :blob_id ],
              name: :index_active_storage_attachments_uniqueness,
              unique: true
  end
end
