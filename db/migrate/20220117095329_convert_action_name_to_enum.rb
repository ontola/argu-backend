class ConvertActionNameToEnum < ActiveRecord::Migration[7.0]
  def up
    remove_index :grant_reset, name: :index_grant_resets_on_edge_id_and_resource_type_and_action_name
    remove_index :permitted_actions, name: :index_permitted_actions_on_action_name_and_resource_type
    remove_index :permitted_actions, name: :index_permitted_actions_on_action_name

    rename_column :grant_resets, :action_name, :action_name_string
    rename_column :permitted_actions, :action_name, :action_name_string
    add_column :grant_resets, :action_name, :integer
    add_column :permitted_actions, :action_name, :integer

    add_index :permitted_actions, :action_name
    add_index :grant_resets, :action_name
    add_index :permitted_actions, %i[action_name resource_type]
    add_index :grant_resets, %i[edge_id resource_type action_name]

    [GrantReset, PermittedAction].each do |klass|
      klass.action_names.each do |key, value|
        klass.where(action_name_string: key).update_all(action_name: value)
      end
    end
    change_column_null :grant_resets, :action_name, false
    change_column_null :permitted_actions, :action_name, false

    remove_column :grant_resets, :action_name_string
    remove_column :permitted_actions, :action_name_string
  end
end
