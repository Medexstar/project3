class CreatePostcodes < ActiveRecord::Migration
  def change
    create_table :postcodes do |t|
      t.float :lat
      t.float :long
      t.integer :code

      t.timestamps null: false
    end
  end
end
