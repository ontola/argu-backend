class AddLinkedResourceIdToMenuItems < ActiveRecord::Migration[5.2]
  def change
    add_column :custom_menu_items, :edge_id, :uuid
    change_column_null :custom_menu_items, :href, true

    ContainerNode.find_each do |container|
      container.send(:create_menu_item) unless container = container.parent.primary_container_node
    end
  end
end
