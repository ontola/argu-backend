class ConvertOpinionsToComments < ActiveRecord::Migration[5.1]
  def change
    add_column :votes, :comment_id, :integer
    add_foreign_key :votes, :comments

    remove_index :votes, name: 'index_votes_on_voteable_id_and_voteable_type_and_creator_id'
    add_column :votes, :primary, :bool, default: true, null: false
    add_index :votes,
              [:voteable_id, :voteable_type, :creator_id, :primary],
              unique: true,
              where: '("primary" is true)',
              name: 'index_votes_on_voteable_id_and_voteable_type_and_creator_id'
  end
end
