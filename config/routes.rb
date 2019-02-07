# frozen_string_literal: true

Rails.application.routes.draw do
  resources :texts
  devise_for :users
  root to: 'texts#index'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
