class AddTypeToGroups < ActiveRecord::Migration[7.0]
  def change
    add_column :groups, :group_type, :integer, default: 0, null: false
    add_index :groups, :group_type

    Page.find_each do |page|
      ActsAsTenant.with_tenant(page) do
        page.send(:build_default_group, :users, :users).save!
        page.send(:create_membership, page.users_group, User.community, Profile.community)
        page.send(:create_membership, page.users_group, User.guest, Profile.guest)
        Grant.where(root_id: page.uuid, group_id: -1).update_all(group_id: page.users_group.id)
      end
    end
  end
end
