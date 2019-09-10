class AddEmploymentGrants < ActiveRecord::Migration[5.2]
  def change
    if Apartment::Tenant.current == 'rivm'
      @actions = HashWithIndifferentAccess.new

      %w[Employment].each do |type|
        %w[create show update destroy trash]
          .each do |action|
          @actions["#{type.underscore}_#{action}"] =
            PermittedAction.create!(
              title: "#{type.underscore}_#{action}",
              resource_type: type,
              parent_type: '*',
              action: action.split('_').first
            )
        end
      end

      show_actions =
        %i[employment_show].map { |a| @actions[a] }

      spectate = GrantSet.spectator
      spectate.permitted_actions << show_actions
      spectate.save!(validate: false)

      participate = GrantSet.participator
      participate.permitted_actions << show_actions
      participate.permitted_actions << %i[employment_create].map { |a| @actions[a] }
      participate.save!(validate: false)

      initiate = GrantSet.initiator
      initiate.permitted_actions << show_actions
      initiate.permitted_actions << %i[employment_create].map { |a| @actions[a] }
      initiate.save!(validate: false)

      moderate = GrantSet.moderator
      moderate.permitted_actions << show_actions
      moderate.permitted_actions << %i[employment_create].map { |a| @actions[a] }
      moderate.permitted_actions << %i[employment_update].map { |a| @actions[a] }
      moderate.save!(validate: false)

      administrate = GrantSet.administrator
      administrate.permitted_actions << show_actions
      administrate.permitted_actions << %i[employment_create].map { |a| @actions[a] }
      administrate.permitted_actions << %i[employment_update].map { |a| @actions[a] }
      administrate.permitted_actions << %i[employment_destroy].map { |a| @actions[a] }
      administrate.save!(validate: false)

      staff = GrantSet.staff
      staff.permitted_actions << show_actions
      staff.permitted_actions << %i[employment_create].map { |a| @actions[a] }
      staff.permitted_actions << %i[employment_update].map { |a| @actions[a] }
      staff.permitted_actions << %i[employment_destroy].map { |a| @actions[a] }
      staff.save!(validate: false)
    end
  end
end
