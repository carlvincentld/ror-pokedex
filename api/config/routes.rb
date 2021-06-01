Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  get "/pokedex/pagination", to: "pokedex#pagination", as: :pokedex_pagination

  resources :pokedex, :expect => :update_entry
end
