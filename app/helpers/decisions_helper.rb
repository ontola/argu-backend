# frozen_string_literal: true

# Helper methods for decisions
module DecisionsHelper
  include UrlHelper

  # @param [User, nil] user The User the Decision is assigned to. Nil if the Decision is assigned to a group
  # @param [Group] group The Group the Decision is assigned to.
  # @param [Boolean] create_link Set to true to link the name to the user's Profile
  # @return [String]
  def assigned_name(user, group, create_link)
    if user.present?
      user =
        if create_link
          link_to(user.profile.display_name, user_path(user))
        else
          user.profile.display_name
        end
      "#{user} (#{group.name_singular})"
    else
      group.display_name
    end
  end

  # @param [ActiveRecord::Base] resource An ActiveRecord with `has_many :decisions`
  # @return [Hash]
  def decision_items(resource)
    items =
      if resource.decisions.unpublished.present?
        [
          link_item(t('decisions.edit_draft'),
                    edit_motion_decision_path(resource, resource.decisions.last),
                    fa: 'pencil')
        ]
      elsif resource.assigned_to_user?(current_user)
        Decision.actioned_keys.map do |state|
          link_item(t("decisions.action.#{state}"),
                    new_motion_decision_path(resource, state: state),
                    fa: decision_icon(Decision.new(state: state)))
        end
      else
        [
          link_item(t('decisions.action.forwarded'),
                    new_motion_decision_path(resource, state: 'forwarded'),
                    fa: decision_icon(Decision.new(state: 'forwarded')))
        ]
      end

    {
      title: t('decisions.take_decision'),
      fa: 'fa-gavel',
      sections: [items: items],
      defaultAction: motion_decisions_path(resource)
    }
  end

  def decision_url(decision, opts = {})
    polymorphic_url([decision.parent_model, decision], opts)
  end

  def decision_path(decision, opts = {})
    decision_url(decision, opts.merge(only_path: true))
  end

  def edit_decision_url(decision, opts = {})
    polymorphic_url([:edit, decision.parent_model, decision], opts)
  end

  def edit_decision_path(decision, opts = {})
    edit_decision_url(decision, opts.merge(only_path: true))
  end

  # @return [String]
  def decision_state(decision)
    if decision.forwarded? && decision.persisted?
      t('decisions.forwarded_to', to: assigned_name(decision.forwarded_user, decision.forwarded_group, false))
    elsif decision.state_changed?
      t("decisions.action.#{decision.state}")
    else
      t("decisions.#{decision.state}")
    end
  end

  # @return [Array]
  def group_select_options(forum)
    [{disabled: true, value: '0', label: t('decisions.find_user_info')}] +
      forum.page.groups.map do |group|
        {
          value: group.id.to_s,
          label: group.display_name
        }
      end
  end
end
