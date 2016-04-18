class CreateDecisions < ActiveRecord::Migration
  def up
    create_table :decisions do |t|
      t.integer :forum_id, null: false
      t.integer :group_id, null: false
      t.integer :user_id
      t.integer :publisher_id
      t.integer :creator_id
      t.text :content, default: '', null: false
      t.integer :state, null: false
      t.integer :decisionable_id, null: false
      t.string :decisionable_type, null: false
      t.integer :forwarded_to_id
      t.timestamps null: false
    end

    Motion.find_each do |motion|
      create_decision(motion)
    end

    add_foreign_key :decisions, :forums
    add_foreign_key :decisions, :groups
    add_foreign_key :decisions, :users
    add_foreign_key :decisions, :users, column: :publisher_id
    add_foreign_key :decisions, :profiles, column: :creator_id
    add_foreign_key :decisions, :decisions, column: :forwarded_to_id
  end

  def down
    Decision.destroy_all

    drop_table :decisions
  end

  private

  def create_decision(motion)
    motion.decisions << Decision
                          .pending
                          .new(
                            group: motion.forum.managers_group,
                            forum: motion.forum)
    motion.decisions.last.build_edge(user: motion.publisher, parent: motion.edge)
    motion.save
  end
end
