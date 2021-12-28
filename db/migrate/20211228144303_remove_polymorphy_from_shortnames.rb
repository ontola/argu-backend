class RemovePolymorphyFromShortnames < ActiveRecord::Migration[6.1]
  def change
    Shortname.where(owner_type: 'User').delete_all

    remove_column :shortnames, :owner_type

    add_foreign_key :shortnames, :edges, column: :owner_id, primary_key: :uuid
  end
end
