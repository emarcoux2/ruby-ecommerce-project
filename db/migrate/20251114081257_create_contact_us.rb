class CreateContactUs < ActiveRecord::Migration[8.1]
  def change
    create_table :contact_us do |t|
      t.string :title
      t.string :content

      t.timestamps
    end
  end
end
