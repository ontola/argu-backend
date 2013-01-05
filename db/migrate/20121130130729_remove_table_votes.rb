class RemoveTableVotes < ActiveRecord::Migration
  def up
  	drop_table :votes
  	remove_column :statements, :pro_count
  	remove_column :statements, :con_count
  end

  def down
  	create_table "votes", :force => true do |t|
	    t.integer  "argument_id", :null => false
	    t.integer  "user_id",              :null => false
	    t.integer  "vote_type"
	    t.datetime "created_at",           :null => false
	    t.datetime "updated_at",           :null => false
	end
	add_index "votes", ["argument_id", "user_id"], :name => "index_votes_on_argument_id_and_user_id", :unique => true

	add_column :statements, :pro_count, :integer, :default => 0
  	add_column :statements, :con_count, :integer, :default => 0

  	Statement.reset_column_information
    Statement.all.each do |s|
      s.update_attribute :pro_count, s.arguments.where(:pro==true).length
      s.update_attribute :pro_count, s.arguments.where(:pro==true).length
    end
  end
end
