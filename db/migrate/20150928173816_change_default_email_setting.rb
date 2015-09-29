class ChangeDefaultEmailSetting < ActiveRecord::Migration
  def change
    change_column_default :users, :follows_email, 0
  end
end
