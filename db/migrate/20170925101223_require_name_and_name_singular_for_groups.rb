class RequireNameAndNameSingularForGroups < ActiveRecord::Migration[5.1]
  def change
    Group.public.update(name_singular: 'User')

    change_column_null :groups, :name, false
    change_column_null :groups, :name_singular, false
  end
end
