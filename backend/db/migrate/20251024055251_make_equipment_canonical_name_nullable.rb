class MakeEquipmentCanonicalNameNullable < ActiveRecord::Migration[8.0]
  def change
    change_column_null :equipment, :canonical_name, true
  end
end
