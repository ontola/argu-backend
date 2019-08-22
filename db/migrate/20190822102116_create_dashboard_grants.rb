class CreateDashboardGrants < ActiveRecord::Migration[5.2]
  def change
    @actions = HashWithIndifferentAccess.new
    %w[create show update destroy trash].each do |action|
      @actions["dashboard_#{action}"] =
        PermittedAction.create!(
          title: "dashboard_#{action}",
          resource_type: 'Dashboard',
          parent_type: '*',
          action: action.split('_').first
        )
    end

    GrantSet.where(root_id: nil).find_each do |grant_set|
      actions = [@actions[:dashboard_show]]
      actions << [@actions[:dashboard_update], @actions[:dashboard_destroy]] if grant_set.title == 'administrator'
      actions << [@actions[:dashboard_create], @actions[:dashboard_update], @actions[:dashboard_destroy]] if grant_set.title == 'staff'
      grant_set.permitted_actions << actions
      grant_set.save!(validate: false)
    end
  end
end
