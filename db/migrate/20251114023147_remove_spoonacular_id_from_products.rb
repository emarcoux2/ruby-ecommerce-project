class RemoveSpoonacularIdFromProducts < ActiveRecord::Migration[8.1]
  def change
    remove_column :products, :spoonacular_id, :integer
  end
end
