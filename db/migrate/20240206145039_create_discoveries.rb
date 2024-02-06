class CreateDiscoveries < ActiveRecord::Migration[7.1]
  def change
    create_table :discoveries do |t|
      t.references :user, null: false, foreign_key: true
      t.references :element, null: false, foreign_key: true

      t.timestamps
    end
  end
end
