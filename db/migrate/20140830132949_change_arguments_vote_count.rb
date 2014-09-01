class ChangeArgumentsVoteCount < ActiveRecord::Migration
  def change
    rename_column :arguments, :votes_count, :votes_pro_count
  end
end
