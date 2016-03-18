class AddProCountConCountToArguments < ActiveRecord::Migration
  def self.up
    # Drop old cache columns
    remove_column :statements, :vote_pro_count
    remove_column :statements, :vote_con_count
    remove_column :statements, :vote_neutral_count
    remove_column :arguments, :votes_count
    remove_column :opinions, :votes_count

    # Add the new ones
    add_column :statements, :votes_pro_count, :integer, :null => false, :default => 0
    add_column :statements, :votes_con_count, :integer, :null => false, :default => 0
    add_column :statements, :votes_neutral_count, :integer, :null => false, :default => 0

    add_column :statements, :argument_pro_count, :integer, :null => false, :default => 0
    add_column :statements, :argument_con_count, :integer, :null => false, :default => 0

    add_column :statements, :opinion_pro_count, :integer, :null => false, :default => 0
    add_column :statements, :opinion_con_count, :integer, :null => false, :default => 0

    add_column :arguments, :votes_count, :integer, :null => false, :default => 0
    add_column :arguments, :comments_count, :integer, :null => false, :default => 0

    add_column :opinions, :votes_count, :integer, :null => false, :default => 0
    add_column :opinions, :comments_count, :integer, :null => false, :default => 0
  end

  def self.down
    remove_column :statements, :votes_pro_count
    remove_column :statements, :votes_con_count
    remove_column :statements, :votes_neutral_count

    remove_column :statements, :argument_pro_count
    remove_column :statements, :argument_con_count

    remove_column :statements, :opinion_pro_count
    remove_column :statements, :opinion_con_count

    remove_column :arguments, :votes_count
    remove_column :arguments, :comments_count
    remove_column :opinions, :votes_count
    remove_column :opinions, :comments_count

    # Old ones didn't work, so no need to add them
  end
end
