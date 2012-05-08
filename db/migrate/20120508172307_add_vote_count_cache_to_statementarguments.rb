class AddVoteCountCacheToStatementarguments < ActiveRecord::Migration
  def up
  	add_column :statementarguments, :vote_count_cache, :integer, :default => 0
  end

  def down
  	remove_column :statementarguments, :vote_count_cache
  end
end
