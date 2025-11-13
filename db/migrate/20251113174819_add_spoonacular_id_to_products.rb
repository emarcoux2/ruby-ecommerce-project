class AddSpoonacularIdToProducts < ActiveRecord::Migration[8.1]
  def change
    add_column :products, :spoonacular_id, :integer
    add_index :products, :spoonacular_id
  end
end
