class AddPermanentAndSendMailAfterToNotifications < ActiveRecord::Migration[5.0]
  def change
    add_column :notifications, :permanent, :bool, default: false, null: false
    add_column :notifications, :send_mail_after, :datetime
  end
end
