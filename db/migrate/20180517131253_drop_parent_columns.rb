class DropParentColumns < ActiveRecord::Migration[5.1]
  def change
    remove_column :arguments, :motion_id, :integer
    remove_column :arguments, :forum_id, :integer
    remove_column :blog_posts, :forum_id, :integer
    remove_column :blog_posts, :blog_postable_id, :integer
    remove_column :blog_posts, :blog_postable_type, :integer
    remove_column :comments, :forum_id, :integer
    remove_column :comments, :commentable_id, :integer
    remove_column :comments, :commentable_type, :integer
    remove_column :decisions, :forum_id, :integer
    remove_column :decisions, :decisionable_id, :integer
    remove_column :forums, :page_id, :integer
    remove_column :motions, :forum_id, :integer
    remove_column :motions, :question_id, :integer
    remove_column :questions, :forum_id, :integer
    remove_column :vote_events, :forum_id, :integer
    remove_column :votes, :forum_id, :integer
    remove_column :votes, :voteable_id, :integer
    remove_column :votes, :voteable_type, :integer

    add_index :edges, :uuid, unique: true

    add_column :votes, :voteable_id, :uuid
    add_index :votes,
              [:voteable_id, :creator_id, :primary],
              unique: true,
              where: '("primary" is true)',
              name: 'index_votes_on_voteable_id_and_creator_id'

    add_foreign_key :votes, :edges, column: :voteable_id, primary_key: :uuid

    Vote.connection.update('UPDATE votes SET voteable_id = parents_edges.uuid FROM edges AS edges INNER JOIN edges AS parents_edges ON edges.parent_id = parents_edges.id WHERE edges.owner_id = votes.id AND edges.owner_type = \'Vote\'')

    change_column_null :votes, :voteable_id, false
  end
end
