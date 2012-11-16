class AddVoteProConCount < ActiveRecord::Migration
  def up
  	add_column :statements, :pro_count, :integer, :default => 0
  	add_column :statements, :con_count, :integer, :default => 0

  	Statement.reset_column_information
    Statement.all.each do |s|
      s.update_attribute :pro_count, s.arguments.where(:pro==true).length
      s.update_attribute :pro_count, s.arguments.where(:pro==true).length
    end
  end

  def down
  	remove_column :statements, :pro_count
  	remove_column :statements, :con_count
  end
end
