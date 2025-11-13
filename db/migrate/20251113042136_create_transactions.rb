class CreateTransactions < ActiveRecord::Migration[8.1]
  def change
    create_table :transactions do |t|
      t.references :order, null: false, foreign_key: true
      t.string :currency
      t.decimal :amount
      t.string :status
      t.string :provider
      t.string :provider_transaction_id

      t.timestamps
    end
  end
end
