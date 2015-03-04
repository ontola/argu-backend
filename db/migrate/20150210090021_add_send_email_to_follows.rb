class AddSendEmailToFollows < ActiveRecord::Migration
  def change
    add_column :follows, :send_email, :boolean, default: false
  end
end
