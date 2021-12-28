class RemovePolymorphyFromWidgets < ActiveRecord::Migration[6.1]
  def change
    Widget.joins('LEFT JOIN edges ON edges.uuid = widgets.owner_id WHERE edges.uuid IS NULL').destroy_all

    remove_column :widgets, :owner_type

    add_foreign_key :widgets, :edges, column: :owner_id, primary_key: :uuid
  end
end
