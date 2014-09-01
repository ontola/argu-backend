class RenameAvoteToVote < ActiveRecord::Migration
  def change
    drop_table :votes
    rename_table :avotes, :votes
  end
end
