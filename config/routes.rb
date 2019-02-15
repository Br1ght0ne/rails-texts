# frozen_string_literal: true

Rails.application.routes.draw do
  root to: 'texts#index'

  devise_for :users

  resources :texts do
    get 'tags', to: 'texts#tags', on: :collection, as: :tags
    get 'tags/:tag', to: 'texts#tagged', on: :collection, as: :tagged
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
