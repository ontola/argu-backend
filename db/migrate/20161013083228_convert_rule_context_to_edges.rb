class ConvertRuleContextToEdges < ActiveRecord::Migration[5.0]
  def up
    change_column_null :rules, :context_id, true
    change_column_null :rules, :context_type, true

    add_column :rules, :branch_id, :integer
    add_index :rules, :branch_id
    add_foreign_key :rules, :edges, column: :branch_id

    Rule.find_each do |rule|
      raise "Context edge not found when processing rule '#{rule.id}'" if rule.context.edge.blank?
      rule.update(branch: rule.context.edge)
    end

    change_column_null :rules, :branch_id, false
  end

  def down
    change_column_null :rules, :context_id, false
    change_column_null :rules, :context_type, false

    remove_column :rules, :branch_id, null: false
  end
end
