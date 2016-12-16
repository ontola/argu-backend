class AllowNullForVoteable < ActiveRecord::Migration[5.0]
  def change
    change_column_null :votes, :voteable_id, true
    change_column_null :votes, :voteable_type, true
  end
end
