Rails.application.routes.draw do
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

  get "transactions/index"
  get "transactions/show"
  get "order_products/index"
  get "order_products/show"
  get "orders/index"
  get "orders/show"
  get "payment_methods/index"
  get "payment_methods/show"
  get "addresses/index"
  get "addresses/show"
  get "customers/index"
  get "customers/show"
  get "carts/index"
  get "carts/show"
  get "cart_products/index"
  get "cart_products/show"
  get "categories/index"
  get "categories/show"

  get "/about",   to: "pages#show", page_type: "about"
  get "/contact", to: "pages#show", page_type: "contact"

  get "up" => "rails/health#show", as: :rails_health_check
end
