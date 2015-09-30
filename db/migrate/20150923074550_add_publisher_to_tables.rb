class AddPublisherToTables < ActiveRecord::Migration
  def up

    rename_column :comments, :representative_id, :publisher_id

    add_reference :questions, :publisher, references: :users
    add_foreign_key :questions, :users, column: :publisher_id

    add_reference :motions, :publisher, references: :users
    add_foreign_key :motions, :users, column: :publisher_id

    add_reference :arguments, :publisher, references: :users
    add_foreign_key :arguments, :users, column: :publisher_id

    rename_column :group_responses, :created_by_id, :publisher_id
    remove_column :group_responses, :created_by_type
    GroupResponse.find_each do |n|
      u = Profile.find(n.publisher_id).profileable
      n.update_column(:publisher_id, u.id) if u.is_a? User
    end
    add_foreign_key :group_responses, :users, column: :publisher_id
  end

end
