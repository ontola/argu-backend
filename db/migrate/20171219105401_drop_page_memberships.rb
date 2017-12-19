class DropPageMemberships < ActiveRecord::Migration[5.1]
  def up
    drop_table :page_memberships
  end
end
