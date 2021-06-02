class CreateOtpUniqueIndex < ActiveRecord::Migration[6.0]
  def change
    add_index :otp_secrets, :user_id, unique: true
  end
end
