class AddDiscoveredByToRecipeAndElement < ActiveRecord::Migration[7.1]
  def change
    add_reference :recipes, :discovered_by, foreign_key: { to_table: :users }
    add_column :recipes, :discovered_uuid, :string

    add_reference :elements, :discovered_by, foreign_key: { to_table: :users }
    add_column :elements, :discovered_uuid, :string
  end
end
