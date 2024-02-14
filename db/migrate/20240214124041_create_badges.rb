class CreateBadges < ActiveRecord::Migration[7.1]
  def change
    create_table :badges do |t|
      t.string :name
      t.string :icon
      t.string :description

      t.timestamps
    end
  end
end
