class AddIsTrashedToArgumentsAndComments < ActiveRecord::Migration
  def up
    add_column :arguments, :is_trashed, :boolean, default: false
    add_column :comments, :is_trashed, :boolean, default: false

    Argument.all.each do |a|
      a.is_trashed = false
      a.save
    end
    Comment.all.each do |a|
      a.is_trashed = false
      a.save
    end
  end

  def down
    remove_column :arguments, :is_trashed
    remove_column :comments, :is_trashed
  end
end
