Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  root  to: "users#route_not_found"

  get "/api/v1" => "users#welcome"
  get "/api/v1/refer" => "users#get_referral_url"
  get "/api/v1/user" => "users#get_user_by_id"
  post "/api/v1/register" => "users#create_user"
  post "/api/v1/login" => "users#authenticate_user"
end
