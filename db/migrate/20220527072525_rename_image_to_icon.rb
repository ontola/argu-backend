class RenameImageToIcon < ActiveRecord::Migration[7.0]
  def change
    rename_column :custom_menu_items, :image, :icon
  end
end
