class EnablePgTrgmWithIndexes < ActiveRecord::Migration[8.0]
  def up
    enable_extension 'pg_trgm'
    add_index :ingredients, :canonical_name, using: :gin, opclass: :gin_trgm_ops, name: 'index_ingredients_on_canonical_name_trgm'
    add_index :ingredient_aliases, :alias, using: :gin, opclass: :gin_trgm_ops, name: 'index_ingredient_aliases_on_alias_trgm'
  end

  def down
    remove_index :ingredients, name: 'index_ingredients_on_canonical_name_trgm'
    remove_index :ingredient_aliases, name: 'index_ingredient_aliases_on_alias_trgm'
    disable_extension 'pg_trgm'
  end
end
