class CreateDecisions < ActiveRecord::Migration
  def up
    create_table :decisions do |t|
      t.integer :forum_id, null: false
      t.integer :decisionable_id, null: false
      t.integer :forwarded_group_id
      t.integer :forwarded_user_id
      t.integer :publisher_id, null: false
      t.integer :creator_id, null: false
      t.integer :step, null: false, default: 0
      t.text :content, default: '', null: false
      t.integer :state, null: false, default: 0
      t.boolean :is_published, null: false, default: false
      t.timestamps null: false
    end

    add_foreign_key :decisions, :edges, column: :decisionable_id
    add_foreign_key :decisions, :forums
    add_foreign_key :decisions, :groups, column: :forwarded_group_id
    add_foreign_key :decisions, :users, column: :forwarded_user_id
    add_foreign_key :decisions, :users, column: :publisher_id
    add_foreign_key :decisions, :profiles, column: :creator_id
  end

  def down
    Decision.destroy_all

    drop_table :decisions
  end

  private
end
