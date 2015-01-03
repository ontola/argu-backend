class AddVisibilityToForum < ActiveRecord::Migration
  def change
    add_column :forums, :visibility, :integer, default: 1
  end
end
