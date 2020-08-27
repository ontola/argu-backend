class RenameRedirectUrl < ActiveRecord::Migration[6.0]
  def change
    rename_column :users, :r, :redirect_url
  end
end
