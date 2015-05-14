class AddFieldsToGroups < ActiveRecord::Migration
  def up
    add_column :groups, :name_singular, :string
    add_column :groups, :max_responses_per_member, :integer, default: 1
    add_column :groups, :icon, :string
  end
end
