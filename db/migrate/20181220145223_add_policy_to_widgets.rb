class AddPolicyToWidgets < ActiveRecord::Migration[5.2]
  def change
    add_column :widgets, :primary_resource_id, :uuid
    add_column :widgets, :permitted_action_id, :integer
    Widget.update_all('primary_resource_id = owner_id')
    Widget.update_all(permitted_action_id: PermittedAction.find_by(title: 'forum_show').id)

    Widget.new_motion.update_all(permitted_action_id: PermittedAction.find_by(title: 'motion_create').id)
    Widget.new_question.update_all(permitted_action_id: PermittedAction.find_by(title: 'question_create').id)

    change_column_null :widgets, :primary_resource_id, false
    change_column_null :widgets, :permitted_action_id, false
  end
end
