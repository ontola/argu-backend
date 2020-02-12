# frozen_string_literal: true

module VisibilityHelper
  def visible_for_group_ids(resource)
    @visible_for_group_ids ||= {}
    @visible_for_group_ids[resource] ||=
      user_context
        .grant_tree_for(resource.persisted_edge)
        .granted_group_ids(resource.persisted_edge)
  end

  def visible_for_string(resource)
    groups = visible_for_group_ids(resource)
    return I18n.t('groups.visible_for_everybody') if groups.include?(Group::PUBLIC_ID)

    I18n.t('groups.visible_for', groups: Group.find(groups).pluck(:name).to_sentence)
  end

  def visibility_icon(resource)
    visible_for_group_ids(resource).include?(-1) ? 'globe' : 'group'
  end
end
