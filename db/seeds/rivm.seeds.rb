# frozen_string_literal: true

Tenant.setup_schema('rivm', "#{Rails.application.config.host_name}/omgevingsveiligheid", 'omgevingsveiligheid')

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

  all_grant_sets = GrantSet.reserved
  PermittedAction.create_for_grant_sets('Category', 'show', all_grant_sets)
  PermittedAction.create_for_grant_sets('Risk', 'show', all_grant_sets)
  PermittedAction.create_for_grant_sets('Intervention', 'show', all_grant_sets)
  PermittedAction.create_for_grant_sets('InterventionType', 'show', all_grant_sets)
  PermittedAction.create_for_grant_sets('Measure', 'show', all_grant_sets)
  PermittedAction.create_for_grant_sets('MeasureType', 'show', all_grant_sets)
  PermittedAction.create_for_grant_sets('Incident', 'show', all_grant_sets)
  PermittedAction.create_for_grant_sets('Scenario', 'show', all_grant_sets)

  participator_plus = GrantSet.reserved(except: %w[spectator])

  PermittedAction.create_for_grant_sets('Intervention', 'create', participator_plus)
  PermittedAction.create_for_grant_sets('Measure', 'create', participator_plus)

  initiator_plus = GrantSet.reserved(except: %w[spectator participator])
  PermittedAction.create_for_grant_sets('InterventionType', 'create', initiator_plus)
  PermittedAction.create_for_grant_sets('MeasureType', 'create', initiator_plus)

  moderator_plus = GrantSet.reserved(only: %w[moderator administrator staff])
  PermittedAction.create_for_grant_sets('Category', 'create', moderator_plus)
  PermittedAction.create_for_grant_sets('Category', 'update', moderator_plus)
  PermittedAction.create_for_grant_sets('Risk', 'create', moderator_plus)
  PermittedAction.create_for_grant_sets('Risk', 'update', moderator_plus)
  PermittedAction.create_for_grant_sets('Intervention', 'update', moderator_plus)
  PermittedAction.create_for_grant_sets('InterventionType', 'update', moderator_plus)
  PermittedAction.create_for_grant_sets('Measure', 'update', moderator_plus)
  PermittedAction.create_for_grant_sets('MeasureType', 'update', moderator_plus)
  PermittedAction.create_for_grant_sets('Category', 'trash', moderator_plus)
  PermittedAction.create_for_grant_sets('Risk', 'trash', moderator_plus)
  PermittedAction.create_for_grant_sets('Intervention', 'trash', moderator_plus)
  PermittedAction.create_for_grant_sets('InterventionType', 'trash', moderator_plus)
  PermittedAction.create_for_grant_sets('Measure', 'trash', moderator_plus)
  PermittedAction.create_for_grant_sets('MeasureType', 'trash', moderator_plus)
  PermittedAction.create_for_grant_sets('Incident', 'create', moderator_plus)
  PermittedAction.create_for_grant_sets('Incident', 'update', moderator_plus)
  PermittedAction.create_for_grant_sets('Incident', 'trash', moderator_plus)
  PermittedAction.create_for_grant_sets('Incident', 'destroy', moderator_plus)
  PermittedAction.create_for_grant_sets('Scenario', 'create', moderator_plus)
  PermittedAction.create_for_grant_sets('Scenario', 'update', moderator_plus)
  PermittedAction.create_for_grant_sets('Scenario', 'trash', moderator_plus)
  PermittedAction.create_for_grant_sets('Scenario', 'destroy', moderator_plus)

  administrator_plus = GrantSet.reserved(only: %w[administrator staff])
  PermittedAction.create_for_grant_sets('Category', 'destroy', administrator_plus)
  PermittedAction.create_for_grant_sets('Risk', 'destroy', administrator_plus)
  PermittedAction.create_for_grant_sets('Intervention', 'destroy', administrator_plus)
  PermittedAction.create_for_grant_sets('InterventionType', 'destroy', administrator_plus)
  PermittedAction.create_for_grant_sets('Measure', 'destroy', administrator_plus)
  PermittedAction.create_for_grant_sets('MeasureType', 'destroy', administrator_plus)

  ActsAsTenant.with_tenant(Page.first) do
    Page.first.update!(primary_color: '#007BC7')

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
