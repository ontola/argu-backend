# frozen_string_literal: true

GrantSet::RESERVED_TITLES.each do |title|
  grant_set = GrantSet.find_or_initialize_by(title: title)
  grant_set.save!(validate: false)
  grant_set.grant_sets_permitted_actions.delete_all
end

all_grant_sets = GrantSet.reserved
PermittedAction.create_for_grant_sets('Page', 'show', all_grant_sets)
PermittedAction.create_for_grant_sets('ContainerNode', 'show', all_grant_sets)
PermittedAction.create_for_grant_sets('Forum', 'show', all_grant_sets)
PermittedAction.create_for_grant_sets('Blog', 'show', all_grant_sets)
PermittedAction.create_for_grant_sets('Survey', 'show', all_grant_sets)
PermittedAction.create_for_grant_sets('Dashboard', 'show', all_grant_sets)
PermittedAction.create_for_grant_sets('OpenDataPortal', 'show', all_grant_sets)
PermittedAction.create_for_grant_sets('Question', 'show', all_grant_sets)
PermittedAction.create_for_grant_sets('Motion', 'show', all_grant_sets)
PermittedAction.create_for_grant_sets('Topic', 'show', all_grant_sets)
PermittedAction.create_for_grant_sets('ProArgument', 'show', all_grant_sets)
PermittedAction.create_for_grant_sets('ConArgument', 'show', all_grant_sets)
PermittedAction.create_for_grant_sets('Comment', 'show', all_grant_sets)
PermittedAction.create_for_grant_sets('VoteEvent', 'show', all_grant_sets)
PermittedAction.create_for_grant_sets('Vote', 'show', all_grant_sets)
PermittedAction.create_for_grant_sets('BlogPost', 'show', all_grant_sets)
PermittedAction.create_for_grant_sets('Decision', 'show', all_grant_sets)
PermittedAction.create_for_grant_sets('CreativeWork', 'show', all_grant_sets)
PermittedAction.create_for_grant_sets('CustomAction', 'show', all_grant_sets)
PermittedAction.create_for_grant_sets('Thing', 'show', all_grant_sets)
PermittedAction.create_for_grant_sets('Phase', 'show', all_grant_sets)
PermittedAction.create_for_grant_sets('Project', 'show', all_grant_sets)
PermittedAction.create_for_grant_sets('BudgetShop', 'show', all_grant_sets)
PermittedAction.create_for_grant_sets('Offer', 'show', all_grant_sets)
PermittedAction.create_for_grant_sets('Banner', 'show', all_grant_sets)

participator_plus = GrantSet.reserved(except: %w[spectator])
PermittedAction.create_for_grant_sets('ProArgument', 'create', participator_plus)
PermittedAction.create_for_grant_sets('ConArgument', 'create', participator_plus)
PermittedAction.create_for_grant_sets('Comment', 'create', participator_plus)
PermittedAction.create_for_grant_sets('Vote', 'create', participator_plus)
PermittedAction.create_for_grant_sets('CartDetail', 'create', participator_plus)
PermittedAction.create_for_grant_sets('CartDetail', 'destroy', participator_plus)
PermittedAction.create_for_grant_sets('Order', 'create', participator_plus)

motion_with_question_create = PermittedAction.find_or_create_by!(
  title: 'motion_with_question_create',
  resource_type: 'Motion',
  parent_type: 'Question',
  action: 'create'
)
GrantSet.find_by!(title: 'participator').add(motion_with_question_create)

initiator_plus = GrantSet.reserved(except: %w[spectator participator])
PermittedAction.create_for_grant_sets('Question', 'create', initiator_plus)
PermittedAction.create_for_grant_sets('Motion', 'create', initiator_plus)
PermittedAction.create_for_grant_sets('Topic', 'create', initiator_plus)

moderator_plus = GrantSet.reserved(only: %w[moderator administrator staff])
PermittedAction.create_for_grant_sets('BlogPost', 'create', moderator_plus)
PermittedAction.create_for_grant_sets('Decision', 'create', moderator_plus)
PermittedAction.create_for_grant_sets('Question', 'update', moderator_plus)
PermittedAction.create_for_grant_sets('Motion', 'update', moderator_plus)
PermittedAction.create_for_grant_sets('Topic', 'update', moderator_plus)
PermittedAction.create_for_grant_sets('ProArgument', 'update', moderator_plus)
PermittedAction.create_for_grant_sets('ConArgument', 'update', moderator_plus)
PermittedAction.create_for_grant_sets('BlogPost', 'update', moderator_plus)
PermittedAction.create_for_grant_sets('Decision', 'update', moderator_plus)
PermittedAction.create_for_grant_sets('Question', 'trash', moderator_plus)
PermittedAction.create_for_grant_sets('Motion', 'trash', moderator_plus)
PermittedAction.create_for_grant_sets('Topic', 'trash', moderator_plus)
PermittedAction.create_for_grant_sets('Survey', 'trash', moderator_plus)
PermittedAction.create_for_grant_sets('ProArgument', 'trash', moderator_plus)
PermittedAction.create_for_grant_sets('ConArgument', 'trash', moderator_plus)
PermittedAction.create_for_grant_sets('BlogPost', 'trash', moderator_plus)
PermittedAction.create_for_grant_sets('Comment', 'trash', moderator_plus)

administrator_plus = GrantSet.reserved(only: %w[administrator staff])
PermittedAction.create_for_grant_sets('CreativeWork', 'create', administrator_plus)
PermittedAction.create_for_grant_sets('Page', 'update', administrator_plus)
PermittedAction.create_for_grant_sets('Forum', 'update', administrator_plus)
PermittedAction.create_for_grant_sets('Blog', 'update', administrator_plus)
PermittedAction.create_for_grant_sets('Survey', 'update', administrator_plus)
PermittedAction.create_for_grant_sets('Survey', 'create', administrator_plus)
PermittedAction.create_for_grant_sets('Dashboard', 'update', administrator_plus)
PermittedAction.create_for_grant_sets('CreativeWork', 'update', administrator_plus)
PermittedAction.create_for_grant_sets('CreativeWork', 'trash', administrator_plus)
PermittedAction.create_for_grant_sets('Page', 'destroy', administrator_plus)
PermittedAction.create_for_grant_sets('Forum', 'destroy', administrator_plus)
PermittedAction.create_for_grant_sets('Blog', 'destroy', administrator_plus)
PermittedAction.create_for_grant_sets('Survey', 'destroy', administrator_plus)
PermittedAction.create_for_grant_sets('Dashboard', 'destroy', administrator_plus)
PermittedAction.create_for_grant_sets('CreativeWork', 'destroy', administrator_plus)
PermittedAction.create_for_grant_sets('CustomAction', 'create', administrator_plus)
PermittedAction.create_for_grant_sets('CustomAction', 'update', administrator_plus)
PermittedAction.create_for_grant_sets('CustomAction', 'trash', administrator_plus)
PermittedAction.create_for_grant_sets('CustomAction', 'destroy', administrator_plus)
PermittedAction.create_for_grant_sets('Thing', 'create', administrator_plus)
PermittedAction.create_for_grant_sets('Thing', 'update', administrator_plus)
PermittedAction.create_for_grant_sets('Thing', 'trash', administrator_plus)
PermittedAction.create_for_grant_sets('Thing', 'destroy', administrator_plus)
PermittedAction.create_for_grant_sets('Project', 'update', administrator_plus)
PermittedAction.create_for_grant_sets('Project', 'destroy', administrator_plus)
PermittedAction.create_for_grant_sets('Project', 'create', administrator_plus)
PermittedAction.create_for_grant_sets('Project', 'trash', administrator_plus)
PermittedAction.create_for_grant_sets('BudgetShop', 'update', administrator_plus)
PermittedAction.create_for_grant_sets('BudgetShop', 'destroy', administrator_plus)
PermittedAction.create_for_grant_sets('BudgetShop', 'create', administrator_plus)
PermittedAction.create_for_grant_sets('BudgetShop', 'trash', administrator_plus)
PermittedAction.create_for_grant_sets('Offer', 'update', administrator_plus)
PermittedAction.create_for_grant_sets('Offer', 'destroy', administrator_plus)
PermittedAction.create_for_grant_sets('Offer', 'create', administrator_plus)
PermittedAction.create_for_grant_sets('Offer', 'trash', administrator_plus)
PermittedAction.create_for_grant_sets('Banner', 'destroy', administrator_plus)
PermittedAction.create_for_grant_sets('Banner', 'create', administrator_plus)
PermittedAction.create_for_grant_sets('Banner', 'trash', administrator_plus)
PermittedAction.create_for_grant_sets('Banner', 'update', administrator_plus)
PermittedAction.create_for_grant_sets('Vocabulary', 'create', administrator_plus)
PermittedAction.create_for_grant_sets('Vocabulary', 'update', administrator_plus)
PermittedAction.create_for_grant_sets('Vocabulary', 'destroy', administrator_plus)
PermittedAction.create_for_grant_sets('Term', 'create', administrator_plus)
PermittedAction.create_for_grant_sets('Term', 'update', administrator_plus)
PermittedAction.create_for_grant_sets('Term', 'destroy', administrator_plus)

staff = GrantSet.reserved(only: %w[staff])
PermittedAction.create_for_grant_sets('Forum', 'create', staff)
PermittedAction.create_for_grant_sets('Blog', 'create', staff)
PermittedAction.create_for_grant_sets('Dashboard', 'create', staff)
PermittedAction.create_for_grant_sets('OpenDataPortal', 'update', staff)
PermittedAction.create_for_grant_sets('OpenDataPortal', 'destroy', staff)
PermittedAction.create_for_grant_sets('Question', 'destroy', staff)
PermittedAction.create_for_grant_sets('Motion', 'destroy', staff)
PermittedAction.create_for_grant_sets('Topic', 'destroy', staff)
PermittedAction.create_for_grant_sets('ProArgument', 'destroy', staff)
PermittedAction.create_for_grant_sets('ConArgument', 'destroy', staff)
PermittedAction.create_for_grant_sets('BlogPost', 'destroy', staff)
PermittedAction.create_for_grant_sets('Comment', 'destroy', staff)

if Apartment::Tenant.current == 'rivm'
  PermittedAction.create_for_grant_sets('Intervention', 'show', all_grant_sets)
  PermittedAction.create_for_grant_sets('InterventionType', 'show', all_grant_sets)
  PermittedAction.create_for_grant_sets('Measure', 'show', all_grant_sets)

  PermittedAction.create_for_grant_sets('Intervention', 'create', participator_plus)
  PermittedAction.create_for_grant_sets('Measure', 'create', participator_plus)

  PermittedAction.create_for_grant_sets('InterventionType', 'create', initiator_plus)

  PermittedAction.create_for_grant_sets('Intervention', 'update', moderator_plus)
  PermittedAction.create_for_grant_sets('InterventionType', 'update', moderator_plus)
  PermittedAction.create_for_grant_sets('Measure', 'update', moderator_plus)
  PermittedAction.create_for_grant_sets('Intervention', 'trash', moderator_plus)
  PermittedAction.create_for_grant_sets('InterventionType', 'trash', moderator_plus)
  PermittedAction.create_for_grant_sets('Measure', 'trash', moderator_plus)

  PermittedAction.create_for_grant_sets('Intervention', 'destroy', administrator_plus)
  PermittedAction.create_for_grant_sets('InterventionType', 'destroy', administrator_plus)
  PermittedAction.create_for_grant_sets('Measure', 'destroy', administrator_plus)
end
