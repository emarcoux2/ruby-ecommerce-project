ActiveAdmin.register Product do
  permit_params :name, :quantity, :category_id, :price, :unit, :is_active, :description, :sku, :image

  index do
    selectable_column
    id_column
    column :name
    column :category
    column :price
    column :quantity
    column :is_active
    column :created_at
    column "Image" do |product|
      if product.image.attached?
        image_tag url_for(product.image), width: 50
      elsif product.image_url.present?
        image_tag product.image_url, width: 50
      end
    end
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
      f.input :image, as: :file, hint: (f.object.image.attached? ? image_tag(url_for(f.object.image), width: 100) : content_tag(:span, "No image yet"))
    end
    f.actions
  end

  show do
    attributes_table do
      row :name
      row :price
      row :description
      row :category
      row :image do |product|
        if product.image.attached?
          image_tag url_for(product.image)
        elsif product.image_url.present?
          image_tag product.image_url
        end
      end
    end
  end
end
