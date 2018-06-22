class DropEdgeableTables < ActiveRecord::Migration[5.1]
  def change
    drop_table :decisions, force: :cascade
    drop_table :comments, force: :cascade
    drop_table :forums, force: :cascade
    drop_table :votes, force: :cascade
    drop_table :linked_records, force: :cascade
    drop_table :blog_posts, force: :cascade
    drop_table :questions, force: :cascade
    drop_table :vote_events, force: :cascade
    drop_table :arguments, force: :cascade
    drop_table :pages, force: :cascade
    drop_table :motions, force: :cascade
  end
end
