class CreateAbouts < ActiveRecord::Migration[8.1]
  def change
    create_table :abouts do |t|
      t.string :title
      t.text :content

      t.timestamps
    end
  end
end
