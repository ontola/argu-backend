class RenameEmailsToEmailAddresses < ActiveRecord::Migration[5.1]
  def change
    rename_table :emails, :email_addresses
  end
end
