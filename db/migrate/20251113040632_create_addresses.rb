class CreateAddresses < ActiveRecord::Migration[8.1]
  def change
    create_table :addresses do |t|
      t.references :customer, null: false, foreign_key: true
      t.string :street
      t.string :city
      t.string :province
      t.string :postal_code
      t.boolean :is_primary

      t.timestamps
    end
  end
end
