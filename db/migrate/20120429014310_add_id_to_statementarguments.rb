class AddIdToStatementarguments < ActiveRecord::Migration
  def change
  	add_column :statementarguments, :id, :primary_key
  end
end
