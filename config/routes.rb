Rails.application.routes.draw do
  devise_for :customers
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  namespace :admin do
    resources :products
    resources :customers
  end

  root to: "pages#home"

  resources :addresses
  resources :products, only: %i[ index show ]
  resources :categories, only: %i[ index show ]
  resources :cart_products, only: %i[ index show ]
  resources :orders, only: %i[ index show ]

  resource :cart, only: %i[ show update destroy ] do
    post :add
  end

  scope "/checkout" do
    post "create_session", to: "checkout#create_checkout_session", as: "checkout_create_session"
    get "cart", to: "checkout#cart", as: "checkout_cart"
    get "success", to: "checkout#success", as: "checkout_success"
    get "cancel", to: "checkout#cancel", as: "checkout_cancel"
end

  get "checkout/address", to: "checkout#address"
  post "checkout/set_address", to: "checkout#set_address"

  get "customers/index"
  get "customers/show"

  get "/about",   to: "pages#show", page_type: "about"
  get "/contact", to: "pages#show", page_type: "contact"

  get "up" => "rails/health#show", as: :rails_health_check
end
