class CreatePaymentMethods < ActiveRecord::Migration[8.1]
  def change
    create_table :payment_methods do |t|
      t.references :customer, null: false, foreign_key: true
      t.string :payment_method
      t.string :provider

      t.timestamps
    end
  end
end
