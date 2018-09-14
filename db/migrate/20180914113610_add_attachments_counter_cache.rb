class AddAttachmentsCounterCache < ActiveRecord::Migration[5.2]
  def change
    add_column :profiles, :attachments_count, :integer, default: 0, null: false
    add_column :edges, :attachments_count, :integer, default: 0, null: false
    add_column :banners, :attachments_count, :integer, default: 0, null: false
  end
end
