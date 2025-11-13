class CreateProducts < ActiveRecord::Migration[8.1]
  def change
    create_table :products do |t|
      t.string :name
      t.integer :quantity
      t.references :category, null: false, foreign_key: true
      t.decimal :price
      t.string :unit
      t.boolean :is_active

      t.timestamps
    end
  end
end
