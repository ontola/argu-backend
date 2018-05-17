class AllowEdgeOwnerNull < ActiveRecord::Migration[5.1]
  def change
    change_column_null :edges, :owner_id, true
    change_column_null :edges, :owner_type, true
  end
end
