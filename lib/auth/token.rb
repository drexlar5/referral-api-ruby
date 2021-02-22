require 'jwt'

module Auth
  class Token

    def sign_jwt_token(user_data)
      JWT.encode(user_data, Rails.application.secrets.secret_key_base, 'HS256')
    end

    def decode_jwt_token(token)
      JWT.decode(token, Rails.application.secrets.secret_key_base, true, algorithm: 'HS256')
    end
  end
end