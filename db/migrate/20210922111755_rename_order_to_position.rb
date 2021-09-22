class RenameOrderToPosition < ActiveRecord::Migration[6.1]
  def change
    rename_column :custom_menu_items, :order, :position
  end
end
