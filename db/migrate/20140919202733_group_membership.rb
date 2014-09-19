class GroupMembership < ActiveRecord::Migration
  def change
    create_table :group_memberships do |t|
      t.belongs_to :user
      t.belongs_to :group
      t.integer :role, null: false, default: 0
    end
  end
end
