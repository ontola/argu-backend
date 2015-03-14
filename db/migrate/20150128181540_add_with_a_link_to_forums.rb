class AddWithALinkToForums < ActiveRecord::Migration
  def change
    add_column :forums, :visible_with_a_link, :boolean, default: false
  end
end
