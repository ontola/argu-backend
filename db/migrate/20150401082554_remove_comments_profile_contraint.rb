class RemoveCommentsProfileContraint < ActiveRecord::Migration
  def change
    change_column_null :comments, :profile_id, true
  end
end
