class ChangePageMembershipToUsePage < ActiveRecord::Migration
  def change
    rename_column :page_memberships, :forum_id, :page_id
  end
end
