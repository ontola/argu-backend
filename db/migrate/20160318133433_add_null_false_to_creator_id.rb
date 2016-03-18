class AddNullFalseToCreatorId < ActiveRecord::Migration
  def change
    change_column_null(:arguments, :creator_id, false)
    change_column_null(:comments, :creator_id, false)
    change_column_null(:group_responses, :creator_id, false)
    change_column_null(:motions, :creator_id, false)
    change_column_null(:photos, :creator_id, false)
    change_column_null(:questions, :creator_id, false)
    change_column_null(:stepups, :creator_id, false)
  end
end
