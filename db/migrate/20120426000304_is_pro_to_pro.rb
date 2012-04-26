class IsProToPro < ActiveRecord::Migration
  def up
	rename_column :statementarguments, :isPro, :pro
  end

  def down
	rename_column :statementarguments, :pro, :isPro
  end
end
