Rails.application.routes.draw do
  devise_for :customers
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  namespace :admin do
    resources :products
    resources :customers
  end

  root to: "pages#home"

  resources :products, only: %i[ index show ]
  resources :categories, only: %i[ index show ]
  resources :cart_products, only: %i[ index show ]
  resources :orders, only: %i[ index show ]

  resource :cart, only: %i[ show update destroy ] do
    post :add
  end

  scope "/checkout" do
    post "create", to: "checkout#create", as: "checkout_create"
    post "cart", to: "checkout#cart", as: "cart_checkout"
    get "success", to: "checkout#success", as: "checkout_success"
    get "cancel", to: "checkout#cancel", as: "checkout_cancel"
  end

  get "transactions/index"
  get "transactions/show"
  get "order_products/index"
  get "order_products/show"
  get "payment_methods/index"
  get "payment_methods/show"
  get "addresses/index"
  get "addresses/show"
  get "customers/index"
  get "customers/show"
  get "cart_products/index"
  get "cart_products/show"
  get "categories/index"
  get "categories/show"

  get "/about",   to: "pages#show", page_type: "about"
  get "/contact", to: "pages#show", page_type: "contact"

  get "up" => "rails/health#show", as: :rails_health_check
end
