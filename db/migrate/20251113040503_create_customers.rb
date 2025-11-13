class CreateCustomers < ActiveRecord::Migration[8.1]
  def change
    create_table :customers do |t|
      t.string :name
      t.string :email_address
      t.integer :phone_number
      t.string :password_hash

      t.timestamps
    end
  end
end
