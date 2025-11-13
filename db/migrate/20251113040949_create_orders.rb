class CreateOrders < ActiveRecord::Migration[8.1]
  def change
    create_table :orders do |t|
      t.references :customer, null: false, foreign_key: true
      t.decimal :total_price
      t.string :status
      t.string :receipt_url

      t.timestamps
    end
  end
end
