class AddStatementHasManyArguments < ActiveRecord::Migration
  def change
    add_foreign_key "arguments", "statements", :name => "arguments_statement_id_fk"
  end
end
