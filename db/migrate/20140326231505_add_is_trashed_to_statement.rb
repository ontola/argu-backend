class AddIsTrashedToStatement < ActiveRecord::Migration
  def up
    add_column :statements, :is_trashed, :boolean, default: false
  end
end
