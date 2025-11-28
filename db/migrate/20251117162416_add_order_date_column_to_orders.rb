class AddOrderDateColumnToOrders < ActiveRecord::Migration[8.1]
  def change
    add_column :orders, :order_date, :datetime
  end
end
