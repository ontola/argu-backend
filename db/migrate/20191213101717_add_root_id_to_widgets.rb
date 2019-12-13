class AddRootIdToWidgets < ActiveRecord::Migration[5.2]
  def change
    Widget.joins('LEFT JOIN edges ON edges.uuid = widgets.owner_id AND widgets.owner_type = \'Edge\'').where('edges.uuid IS NULL').destroy_all
    add_column :widgets, :root_id, :uuid
    Widget.connection.update('UPDATE widgets SET root_id = edges.root_id FROM edges WHERE edges.uuid = widgets.owner_id AND widgets.owner_type = \'Edge\'')
    change_column_null :widgets, :root_id, false

    CustomMenuItem.joins('LEFT JOIN edges ON edges.uuid = custom_menu_items.resource_id').where('edges.uuid IS NULL').destroy_all
    add_column :custom_menu_items, :root_id, :uuid
    CustomMenuItem.connection.update('UPDATE custom_menu_items SET root_id = edges.root_id FROM edges WHERE edges.uuid = custom_menu_items.resource_id')
    change_column_null :custom_menu_items, :root_id, false

    remove_column :widgets, :primary_resource_id
  end
end
