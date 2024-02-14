Rails.application.routes.draw do
  # Defines the root path route ("/")
  root "static#game"
  get "leaderboard", to: "profile#index", as: "leaderboard"
  get "challenge", to: "static#challenge", as: "challenge"
  
  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  get "profile", to: redirect("/leaderboard"), as: :profiles_path
  resources :profile
  
  resources :elements
  scope :api do
    defaults format: :json do
      get "craft", to: "api#craft"
    end
  end

end
