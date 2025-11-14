ActiveAdmin.register About do
  permit_params :title, :content

  index do
    selectable_column
    id_column
    column :title
    column :content
    column :created_at
    column :updated_at
    actions
  end

  form do |f|
    f.inputs "About Page Details" do
      f.input :title
      f.input :content, as: :text
    end
    f.actions
  end
end
