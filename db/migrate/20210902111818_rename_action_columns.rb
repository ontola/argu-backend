class RenameActionColumns < ActiveRecord::Migration[6.0]
  def change
    rename_column :grant_resets, :action, :action_name
    rename_column :permitted_actions, :action, :action_name
  end
end
