class CreateStatementarguments < ActiveRecord::Migration
  def change
    create_table :statementarguments do |t|
      t.boolean :pro

      t.timestamps
    end
  end
end
