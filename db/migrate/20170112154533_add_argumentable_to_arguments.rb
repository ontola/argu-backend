class AddArgumentableToArguments < ActiveRecord::Migration[5.0]
  def change
    rename_column :arguments, :motion_id, :argumentable_id
    add_column :arguments, :argumentable_type, :string

    Argument.where('argumentable_id IS NOT NULL').update_all(argumentable_type: 'Motion')
    Argument.where('argumentable_id IS NULL').find_each do |argument|
      argument.update!(argumentable_id: argument.parent_model.id, argumentable_type: argument.parent_model.class.name)
    end

    change_column_null :arguments, :argumentable_type, false
  end
end
