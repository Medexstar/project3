class CreateLocations < ActiveRecord::Migration
  def change
    create_table :locations do |t|
      t.string :name
      t.string :location_id
      t.float :lat
      t.float :long
      t.integer :postcode
      t.datetime :last_update
      t.string :summary

      t.timestamps null: false
    end
  end
end
