class AddRemoteUrlToMediaObjects < ActiveRecord::Migration[5.1]
  def change
    add_column :media_objects, :remote_url, :string
  end
end
