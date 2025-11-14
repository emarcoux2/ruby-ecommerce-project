ActiveAdmin.register ContactUs do
permit_params :title, :content

  form do |f|
    f.inputs "Contact Page" do
      f.input :title
      f.input :content, as: :text
    end
    f.actions
  end
end
