class CreateRecipes < ActiveRecord::Migration[7.1]
  def change
    create_table :recipes do |t|
      t.references :left_element, null: false, foreign_key: { to_table: :elements }
      t.references :right_element, null: false, foreign_key: { to_table: :elements }
      t.references :result, foreign_key: { to_table: :elements }
      t.integer :status, default: 0

      t.timestamps
    end
  end
end
