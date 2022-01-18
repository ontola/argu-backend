class ConvertResourceTypeToEnum < ActiveRecord::Migration[7.0]
  def up
    remove_index :grant_resets, name: :index_grant_resets_on_edge_id_and_resource_type_and_action_name

    rename_column :grant_resets, :resource_type, :resource_type_string
    add_column :grant_resets, :resource_type, :integer

    add_index :grant_resets, :resource_type
    add_index :grant_resets, %i[edge_id action_name resource_type]

    GrantReset.resource_types.except.each do |key, value|
      GrantReset.where(resource_type_string: key).update_all(resource_type: value)
    end
    change_column_null :grant_resets, :resource_type, false
    remove_column :grant_resets, :resource_type_string
  end
end
