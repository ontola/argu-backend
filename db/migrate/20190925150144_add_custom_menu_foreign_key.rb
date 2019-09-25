class AddCustomMenuForeignKey < ActiveRecord::Migration[5.2]
  def change
    add_foreign_key :custom_menu_items, :edges, primary_key: :uuid
  end
end
