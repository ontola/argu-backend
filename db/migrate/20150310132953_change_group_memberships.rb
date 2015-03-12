class ChangeGroupMemberships < ActiveRecord::Migration
  def change
    rename_column :group_memberships, :page_id, :member_id

    GroupMembership.all.each do |membership|
      membership.update_attribute :member_id, Page.find(membership.member_id).profile.id
    end
  end
end
