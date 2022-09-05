class AddTypeToGroups < ActiveRecord::Migration[7.0]
  def change
    add_column :groups, :group_type, :integer, default: 0, null: false
    add_index :groups, :group_type

    Page.find_each do |page|
      ActsAsTenant.with_tenant(page) do
        page.send(:create_users_group)
      end
    end
  end
end
