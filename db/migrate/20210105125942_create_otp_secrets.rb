class CreateOtpSecrets < ActiveRecord::Migration[6.0]
  def change
    create_table :otp_secrets do |t|
      t.timestamps
      t.integer :user_id, null: false
      t.string :otp_secret_key, null: false
      t.boolean :active, default: false
    end
  end
end
