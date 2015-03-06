class AddGroupsToSystem < ActiveRecord::Migration
  def change

    create_table :groups do |t|
      t.belongs_to :forum
      t.string :name, default: ''
      t.timestamps
    end
    add_index :groups, [:forum_id, :name], unique: true

    create_table :group_memberships do |t|
      t.belongs_to :group
      t.belongs_to :page
      t.belongs_to :profile, as: :created_by
      t.timestamps
    end
    add_index :group_memberships, [:group_id, :page_id], unique: true

    create_table :group_responses do |t|
      t.belongs_to :forum
      t.belongs_to :group
      t.belongs_to :profile
      t.belongs_to :motion
      t.text :text, default: ''
      t.belongs_to :created_by, polymorphic: true
      t.timestamps
    end
    add_index :group_responses, [:group_id, :forum_id]
    add_index :group_responses, [:group_id, :motion_id]
  end
end
