class RenameOwnerId < ActiveRecord::Migration[6.0]
  def change
    rename_column :otp_secrets, :user_id, :owner_id
  end
end
