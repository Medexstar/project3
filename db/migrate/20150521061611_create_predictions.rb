class CreatePredictions < ActiveRecord::Migration
  def change
    create_table :predictions do |t|

      t.timestamps null: false
    end
  end
end
