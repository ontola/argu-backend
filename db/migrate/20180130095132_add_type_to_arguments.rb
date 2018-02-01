class AddTypeToArguments < ActiveRecord::Migration[5.1]
  def up
    add_column :arguments, :type, :string
    Argument.where(pro: true).update_all(type: 'ProArgument')
    Argument.where(pro: false).update_all(type: 'ConArgument')
    change_column_null :arguments, :type, false
    remove_column :arguments, :pro
  end

  def down
    add_column :arguments, :pro, :bool, default: true
    Argument.where(type: 'ConArgument').update_all(pro: false)
    remove_column :arguments, :type, :string
  end
end
