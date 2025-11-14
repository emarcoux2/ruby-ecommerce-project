class ChangePhoneNumberToString < ActiveRecord::Migration[8.1]
  def change
    change_column :customers, :phone_number, :string
  end
end
