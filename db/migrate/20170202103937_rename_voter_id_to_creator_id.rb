class RenameVoterIdToCreatorId < ActiveRecord::Migration[5.0]
  def change
    rename_column :votes, :voter_id, :creator_id
    remove_column :votes, :voter_type
    add_index :votes, :creator_id
  end
end
