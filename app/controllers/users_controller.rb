class UsersController < ApplicationController
  # skip_before_action :verify_authenticity_token
  before_action :is_auth, only: [:get_referral_url, :get_user_by_id]
  
  def welcome
    render :json => { error: false, message: "hello, Michael" }
  end

  def create_user
    body = params.require(:user).permit(:email, :password)
    user_data = Users::UserService.new.create_user(body, params[:code])
    render :json => { error: false, message: user_data }
  rescue StandardError => error
    render :json => { error: true, message: error }
  end

  def authenticate_user
    body = params.require(:user).permit(:email, :password)
    user_data = Users::UserService.new.authenticate_user(body)
    render :json => { error: false, message: user_data }
  rescue StandardError => error
    render :json => { error: true, message: error }
  end

  def get_referral_url
    referral_data = Users::UserService.new.get_referral_url(request[:user_id])
    render :json => { error: false, message: referral_data }
  rescue StandardError => error
    render :json => { error: true, message: error }
  end

  def get_user_by_id
    user_data = Users::UserService.new.get_user_by_id(request[:user_id])
    render :json => { error: false, message: user_data }
  rescue StandardError => error
    render :json => { error: true, message: error }
  end

  def route_not_found
    render :json => { error: true, message: "Route not found." }
  end

end
