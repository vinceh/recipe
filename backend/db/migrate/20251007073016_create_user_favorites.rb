class CreateUserFavorites < ActiveRecord::Migration[8.0]
  def change
    create_table :user_favorites, id: :uuid do |t|
      t.uuid :user_id, null: false
      t.uuid :recipe_id, null: false

      t.timestamps
    end

    add_foreign_key :user_favorites, :users
    add_foreign_key :user_favorites, :recipes
    add_index :user_favorites, [:user_id, :recipe_id], unique: true
  end
end
