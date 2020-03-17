class AddAttachmentCountToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :attachments_count, :integer, default: 0, null: false
  end
end
