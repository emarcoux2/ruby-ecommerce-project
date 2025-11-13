class CreateOrderProducts < ActiveRecord::Migration[8.1]
  def change
    create_table :order_products do |t|
      t.references :order, null: false, foreign_key: true
      t.integer :quantity
      t.decimal :price_each

      t.timestamps
    end
  end
end
