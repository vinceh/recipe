class CreateUnits < ActiveRecord::Migration[8.0]
  def change
    create_table :units do |t|
      t.string :canonical_name, null: false
      t.integer :category, null: false, default: 0

      t.timestamps
    end

    add_index :units, :canonical_name, unique: true
    add_index :units, :category

    create_table :unit_translations do |t|
      t.references :unit, null: false, foreign_key: true
      t.string :locale, null: false
      t.string :name, null: false

      t.timestamps
    end

    add_index :unit_translations, [:unit_id, :locale], unique: true
    add_index :unit_translations, :locale
  end
end
