class AddScopeToRules < ActiveRecord::Migration
  def change
    add_column :rules, :context_type, :string
    add_column :rules, :context_id, :integer
  end
end
