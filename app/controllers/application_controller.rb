require_relative '../../lib/auth/token'

class ApplicationController < ActionController::API
  before_action :is_auth

  def auth_header
    # { Authorization: 'Bearer <token>' }
    request.headers['Authorization']
  end

  def is_auth
    raise StandardError('Not authenticated') unless auth_header

    token = auth_header.split(' ')[1]

    decoded_token = Auth::Token.new.decode_jwt_token(token)

    raise StandardError('Not authenticated') unless decoded_token
  
    request[:user_id] = decoded_token[0]["user_id"]
  rescue StandardError, JWT::DecodeError => error
    puts error
    render :json => { error: true, message: error}
  end

end
