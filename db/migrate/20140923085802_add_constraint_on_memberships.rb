class AddConstraintOnMemberships < ActiveRecord::Migration
  def change
    add_index :memberships, [:user_id, :organisation_id], unique: true
  end
end
