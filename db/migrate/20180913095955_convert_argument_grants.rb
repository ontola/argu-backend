class ConvertArgumentGrants < ActiveRecord::Migration[5.2]
  def change
    PermittedAction.where(resource_type: 'Argument').find_each do |action|
      con_action = PermittedAction.create!(
        resource_type: 'ConArgument',
        title: "con_#{action.title}",
        parent_type: action.parent_type,
        action: action.action
      )
      action.grant_sets_permitted_actions.pluck(:grant_set_id).each do |grant_set_id|
        GrantSetsPermittedAction.create!(grant_set_id: grant_set_id, permitted_action_id: con_action.id)
      end
      action.update!(resource_type: 'ProArgument', title: "pro_#{action.title}")
    end
  end
end
