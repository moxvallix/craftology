class CreateElements < ActiveRecord::Migration[7.1]
  def change
    create_table :elements do |t|
      t.string :name
      t.string :icon
      t.string :description
      t.boolean :default, default: false

      t.timestamps

      t.index :name
    end
  end
end
