class AddProductIdToOrderProducts < ActiveRecord::Migration[8.1]
  def change
    add_reference :order_products, :product, null: false, foreign_key: true
  end
end
