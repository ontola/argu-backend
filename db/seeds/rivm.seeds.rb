# frozen_string_literal: true

Tenant.setup_schema('rivm', "app.#{Rails.application.config.host_name}/omgevingsveiligheid", 'omgevingsveiligheid')

Apartment::Tenant.switch('rivm') do # rubocop:disable Metrics/BlockLength
  @actions = HashWithIndifferentAccess.new

  %w[Category Risk InterventionType Intervention Measure MeasureType].each do |type|
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
    %i[category_show risk_show intervention_show measure_show intervention_type_show measure_type_show]
      .map { |a| @actions[a] }

  spectate = GrantSet.spectator
  spectate.permitted_actions << show_actions
  spectate.save!(validate: false)

  participate = GrantSet.participator
  participate.permitted_actions << show_actions
  participate.permitted_actions << %i[intervention_create measure_create].map { |a| @actions[a] }
  participate.save!(validate: false)

  initiate = GrantSet.initiator
  initiate.permitted_actions << show_actions
  initiate.permitted_actions <<
    %i[intervention_create measure_create intervention_type_create measure_type_create].map { |a| @actions[a] }
  initiate.save!(validate: false)

  moderate = GrantSet.moderator
  moderate.permitted_actions << show_actions
  moderate.permitted_actions <<
    %i[category_create risk_create intervention_create measure_create intervention_type_create measure_type_create]
      .map { |a| @actions[a] }
  moderate.permitted_actions <<
    %i[category_update risk_update intervention_update measure_update intervention_type_update measure_type_update]
      .map { |a| @actions[a] }
  moderate.permitted_actions <<
    %i[category_trash risk_trash intervention_trash measure_trash intervention_type_trash measure_type_trash]
      .map { |a| @actions[a] }
  moderate.save!(validate: false)

  administrate = GrantSet.administrator
  administrate.permitted_actions << show_actions
  administrate.permitted_actions <<
    %i[category_create risk_create intervention_create measure_create intervention_type_create measure_type_create]
      .map { |a| @actions[a] }
  administrate.permitted_actions <<
    %i[category_update risk_update intervention_update measure_update intervention_type_update measure_type_update]
      .map { |a| @actions[a] }
  administrate.permitted_actions <<
    %i[category_trash risk_trash intervention_trash measure_trash intervention_type_trash measure_type_trash]
      .map { |a| @actions[a] }
  administrate.permitted_actions <<
    %i[category_destroy risk_destroy intervention_destroy measure_destroy
       intervention_type_destroy measure_type_destroy]
      .map { |a| @actions[a] }
  administrate.save!(validate: false)

  staff = GrantSet.staff
  staff.permitted_actions << show_actions
  staff.permitted_actions <<
    %i[category_create risk_create intervention_create measure_create intervention_type_create measure_type_create]
      .map { |a| @actions[a] }
  staff.permitted_actions <<
    %i[category_update risk_update intervention_update measure_update intervention_type_update measure_type_update]
      .map { |a| @actions[a] }
  staff.permitted_actions <<
    %i[category_trash risk_trash intervention_trash measure_trash intervention_type_trash measure_type_trash]
      .map { |a| @actions[a] }
  staff.permitted_actions <<
    %i[category_destroy risk_destroy intervention_destroy measure_destroy
       intervention_type_destroy measure_type_destroy]
      .map { |a| @actions[a] }
  staff.save!(validate: false)

  ActsAsTenant.with_tenant(Page.first) do
    Page.first.update!(accent_background_color: '#007BC7', base_color: '#007BC7', navbar_background: '#007BC7')

    CustomMenuItem.create!(
      menu_type: :navigations,
      resource: Page.first,
      order: 0,
      label: 'risks.plural',
      label_translation: true,
      href: Risk.root_collection.iri
    )
    CustomMenuItem.create!(
      menu_type: :navigations,
      resource: Page.first,
      order: 0,
      label: 'intervention_types.plural',
      label_translation: true,
      href: InterventionType.root_collection.iri
    )
  end
end
