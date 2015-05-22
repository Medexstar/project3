class CreateMeasurements < ActiveRecord::Migration
  def change
    create_table :measurements do |t|
      t.float :temp
      t.float :percip_intensity
      t.float :wind_speed
      t.float :wind_direction
      t.datetime :time
      t.references :location

      t.timestamps null: false
    end
  end
end
