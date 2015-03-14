class AddContraintToVote < ActiveRecord::Migration
  def change
    add_index :votes, [:voteable_id, :voteable_type, :voter_id, :voter_type], name: 'no_duplicate_votes', unique: true, using: :btree
  end
end
