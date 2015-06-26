class AddNotNullContraintToRuleContext < ActiveRecord::Migration
  def up
    change_column_null :rules, :context_type, false
    change_column_null :rules, :context_id, false
  end

  def down
    change_column_null :rules, :context_type, true
    change_column_null :rules, :context_id, true
  end
end
