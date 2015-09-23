class AddRepresentativeToComments < ActiveRecord::Migration
  def up
    add_reference :comments, :representative, references: :users
    add_foreign_key :comments, :users, column: :representative_id
  end

  def down
    remove_reference :comments, :representative
  end
end
