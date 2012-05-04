class AddTableVotes < ActiveRecord::Migration
  def up
  	create_table :votes do |t|
  		t.integer :statementargument_id
  		t.integer :user_id
  		t.integer :vote_type

  		t.timestamps
    end
  end

  def down
  	drop_table :votes
  end
end
