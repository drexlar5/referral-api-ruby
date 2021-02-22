class User < ApplicationRecord
  serialize(:referred_users, Array)
end
