class AddPageMembership < ActiveRecord::Migration
  def change
    create_table :page_memberships do |t|
      t.integer 'profile_id',             null: false
      t.integer 'forum_id',               null: false
      t.integer 'role',       default: 0, null: false
    end
  end
end
