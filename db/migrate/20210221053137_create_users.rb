class CreateUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :users do |t|
      t.string :email 
      t.string :password
      t.integer :credit
      t.string :referral_code
      t.string :user_id
      t.integer :referral_count
      t.string :referred_users
      t.timestamps
    end
  end
end
