class DropStatementArguments < ActiveRecord::Migration
  def change
    drop_table :statementarguments
  end
end
