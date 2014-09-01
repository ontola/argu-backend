class CleanupDatabase < ActiveRecord::Migration
  def change
    add_index :statements, :id
    add_index :statements, :is_trashed

    add_index :arguments, :id
    add_index :arguments, [:statement_id, :id]
    add_index :arguments, [:statement_id, :is_trashed]
    add_index :arguments, [:statement_id, :id, :pro]

    add_index :opinions, :id
    add_index :opinions, [:statement_id, :id]
    add_index :opinions, [:statement_id, :is_trashed]
    add_index :opinions, [:statement_id, :id, :pro]
    add_column :opinions, :votes_abstain_count, :integer, default: 0, null: false

    add_index :comments, [:commentable_id, :commentable_type, :is_trashed], name: 'index_comments_on_id_and_type_and_trashed'

    add_index :votes, [:voteable_id, :voteable_type]
    add_index :votes, [:voteable_id, :voteable_type, :voter_id, :voter_type], name: 'index_votes_on_voter_and_voteable_and_trashed'
    add_index :votes, [:voter_id, :voter_type]

    remove_column :arguments, :argtype
    remove_column :statements, :statetype
  end
end
