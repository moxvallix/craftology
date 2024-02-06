class CreateDiscoveryRecipes < ActiveRecord::Migration[7.1]
  def change
    create_table :discovery_recipes do |t|
      t.references :discovery, null: false, foreign_key: true
      t.references :recipe, null: false, foreign_key: true

      t.timestamps
    end
  end
end
