class AddPublisherIdToVotes < ActiveRecord::Migration
  def up
    add_column :votes, :publisher_id, :integer
    add_foreign_key :votes, :users, column: :publisher_id
    add_foreign_key :votes, :profiles, column: :voter_id
    Vote.find_each do |vote|
      vote.update_column :publisher_id, vote.voter.profileable.id
    end
    change_column_null :votes, :publisher_id, false
  end

  def down
    remove_column :votes, :publisher_id
  end
end
