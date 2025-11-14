ActiveAdmin.register Product do
  permit_params :name, :quantity, :category_id, :price, :unit, :is_active, :image_url, :description, :sku

  index do
    selectable_column
    id_column
    column :name
    column :category
    column :price
    column :quantity
    column :is_active
    column :created_at
    actions
  end

  filter :name
  filter :category
  filter :price
  filter :is_active

  form do |f|
    f.inputs "Product Details" do
      f.input :name
      f.input :description
      f.input :quantity
      f.input :category
      f.input :unit
      f.input :price
      f.input :sku
      f.input :is_active
      f.input :image_url
    end
    f.actions
  end
end
