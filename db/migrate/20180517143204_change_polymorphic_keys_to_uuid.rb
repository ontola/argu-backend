class ChangePolymorphicKeysToUUID < ActiveRecord::Migration[5.1]
  def change
    add_column :profiles, :uuid, :uuid, default: 'uuid_generate_v4()', null: false
    add_column :banners, :uuid, :uuid, default: 'uuid_generate_v4()', null: false

    add_index :profiles, :uuid, unique: true
    add_index :banners, :uuid, unique: true

    add_column :media_objects, :about_uuid, :uuid
    add_column :placements, :placeable_uuid, :uuid
    add_column :custom_menu_items, :resource_uuid, :uuid
    add_column :widgets, :owner_uuid, :uuid

    MediaObject.connection.update('UPDATE media_objects SET about_type = \'Edge\', about_id = edges.id, about_uuid = edges.uuid FROM edges AS edges WHERE edges.owner_id = media_objects.about_id AND edges.owner_type = media_objects.about_type')
    MediaObject.connection.update('UPDATE media_objects SET about_uuid = profiles.uuid FROM profiles WHERE profiles.id = media_objects.about_id AND media_objects.about_type = \'Profile\'')

    Placement.connection.update('UPDATE placements SET placeable_uuid = users.uuid FROM users WHERE users.id = placements.placeable_id AND placements.placeable_type = \'User\'')
    Placement.connection.update('UPDATE placements SET placeable_uuid = edges.uuid FROM edges WHERE edges.id = placements.placeable_id AND placements.placeable_type = \'Edge\'')

    CustomMenuItem.connection.update('UPDATE custom_menu_items SET resource_type = \'Edge\', resource_id = edges.id, resource_uuid = edges.uuid FROM edges WHERE edges.owner_id = custom_menu_items.resource_id AND edges.owner_type = custom_menu_items.resource_type')

    Widget.connection.update('UPDATE widgets SET owner_type = \'Edge\', owner_id = edges.id, owner_uuid = edges.uuid FROM edges WHERE edges.owner_id = widgets.owner_id AND edges.owner_type = widgets.owner_type')

    remove_column :media_objects, :about_id
    remove_column :placements, :placeable_id
    remove_column :custom_menu_items, :resource_id
    remove_column :widgets, :owner_id

    rename_column :media_objects, :about_uuid, :about_id
    rename_column :placements, :placeable_uuid, :placeable_id
    rename_column :custom_menu_items, :resource_uuid, :resource_id
    rename_column :widgets, :owner_uuid, :owner_id

    change_column_null :media_objects, :about_id, false
    change_column_null :placements, :placeable_id, false
    change_column_null :custom_menu_items, :resource_id, false
    change_column_null :widgets, :owner_id, false

    add_index :media_objects, [:about_id, :about_type]
    add_index :placements,
              :placeable_id,
              where: "placement_type = 0 AND placeable_type = 'User'",
              unique: true
    add_index :widgets, [:owner_id, :owner_type]
  end
end
