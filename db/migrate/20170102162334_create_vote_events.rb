class CreateVoteEvents < ActiveRecord::Migration[5.0]
  def change
    create_table :vote_events do |t|
      t.integer :group_id, null: false, default: -1
      t.datetime :starts_at
      t.datetime :ends_at
      t.integer :result, null: false, default: 0
      t.integer :creator_id, null: false
      t.integer :publisher_id, null: false
      t.integer :forum_id
      t.timestamps null: false
      t.index :group_id
    end

    add_foreign_key :vote_events, :groups
    add_foreign_key :vote_events, :users, column: :publisher_id
    add_foreign_key :vote_events, :profiles, column: :creator_id
    add_foreign_key :vote_events, :forums

    Motion.find_each do |motion|
      VoteEvent.create!(
        edge: Edge.new(
          parent: motion.edge,
          user: motion.publisher,
          children_counts: motion.edge.children_counts.slice('votes_neutral', 'votes_pro', 'votes_con')
        ),
        starts_at: motion.created_at,
        creator_id: motion.creator_id,
        publisher_id: motion.publisher_id,
        forum_id: motion.forum_id
      )
      motion.edge.update!(children_counts: motion.edge.children_counts.except('votes_neutral', 'votes_pro', 'votes_con'))
    end

    Vote.joins(edge: :parent).where(parents_edges: {owner_type: 'Motion'}).find_each do |vote|
      vote.edge.update!(parent: vote.parent_model.default_vote_event.edge)
      vote.activities.update_all(recipient_id: vote.parent_model.id, recipient_type: 'VoteEvent')
    end
  end
end
