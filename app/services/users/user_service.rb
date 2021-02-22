require 'bcrypt'
require "securerandom"
require_relative '../../../lib/auth/token'

class Users::UserService

  private def credit_referrer(referrer_id)
    current_user_details = User.find_by({ user_id: referrer_id })

    current_user_details.credit += 10

    User.update({ credit: current_user_details.credit })
  end

  private def update_referrer(referrer, updated_referral_count, updated_referred_users_array)
    User.find_by({ user_id: referrer.user_id })
    .update({
      referral_count: updated_referral_count,
      referred_users: updated_referred_users_array,
    })
  end


  private def update_referrer_referral_data(code, new_user)
    referrer =  User.find_by({ referral_code: code })
    raise StandardError.new("Referral code doesn't exist.") unless referrer
    
    referral_count, referred_users = referrer.values_at(:referral_count, :referred_users)
    
    updated_referral_count = referral_count + 1
    updated_referred_users_array = referred_users.push(new_user.user_id)
    
    update_referrer(referrer, updated_referral_count, updated_referred_users_array)

    [referrer.referral_count + 1, referrer.user_id]
  end

  private def link_to_referrer(code, new_user)
    updated_referral_count, referrer_id = update_referrer_referral_data(
      code,
      new_user
    )

    credit_referrer(referrer_id) if (updated_referral_count % 5) === 0
  end

  def create_user(user_data, query_params)

    email, password = user_data.values_at(:email, :password)
    formatted_email = email.downcase.strip
    hashed_password = BCrypt::Password.create(password)

    user_credit = 0
    user_credit = 10 if query_params


    new_user = User.new({
      email: formatted_email,
      password: hashed_password,
      # credit user that signs up with referral link
      credit: user_credit,
      user_id: SecureRandom.hex(4),
      referral_count: 0
    })
    
    saved_user = new_user.save
    raise StandardError.new('User not created.') unless saved_user

    link_to_referrer(query_params, new_user) if query_params
    
    new_user
  rescue StandardError => e
    puts e
    raise
  end

  def authenticate_user(user_data)

    email, password = user_data.values_at(:email, :password)
    formatted_email = email.downcase.strip

    user_info = User.find_by({ email: formatted_email })
    raise StandardError.new('User does not exist.') unless user_info

    database_password = BCrypt::Password.new(user_info[:password])
    raise StandardError.new('Wrong password.') unless database_password == password

    token = Auth::Token.new.sign_jwt_token({user_id: user_info.user_id})
    raise StandardError.new('Error occurred, could not create token.') unless token

    token
  rescue StandardError => e
    puts e
    raise
  end

  def get_referral_url(user_id)

    user = User.find_by({ user_id: user_id })

    raise StandardError.new('User does not exist.') unless user

    raise StandardError.new('User has created a referral code already.') if user.referral_code

    referral_base_url = Rails.application.secrets.referral_base_url
    referral_id = SecureRandom.hex(4)

    updated_user = User.find_by({ user_id: user_id }).update({ referral_code: referral_id })

    raise StandardError.new('Referral code not created.') unless updated_user

    referral_url_params = "register?code=#{referral_id}"

    "#{referral_base_url}/#{referral_url_params}"
  rescue StandardError => e
    puts e
    raise
  end

  def get_user_by_id(user_id)

    user_details = User.find_by({ user_id: user_id }).attributes.except("password", "id", "user_id")

    raise StandardError.new('User does not exist.') unless user_details
    
    user_details
  rescue StandardError => e
    puts e
    raise
  end
end