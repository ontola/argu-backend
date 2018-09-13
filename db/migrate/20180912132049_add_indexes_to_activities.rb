class AddIndexesToActivities < ActiveRecord::Migration[5.2]
  def change
    add_index :activities, [:root_id, :trackable_id]
    add_index :activities, [:root_id, :key]
    add_index :activities, :trackable_edge_id
    add_index :activities, :recipient_edge_id
    add_index :exports, :edge_id
    add_index :grants, :edge_id
    add_index :publications, :publishable_id
    add_index :edges, :root_id
    add_index :grant_sets, :root_id
    add_index :groups, :root_id
    add_index :shortnames, :root_id
  end
end
