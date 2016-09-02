# frozen_string_literal: true

# Helper methods for decisions
module DecisionsHelper
  # @param [Decision, nil] decision The decision to get the actor for. Nil for the current actor.
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

  # @param [ActiveRecord::Base] resource An ActiveRecord with has_many :decisions
  # @return [Hash]
  def decision_items(resource)
    if resource.assigned_to_user?(current_user)
      items = Decision.actioned_keys.map do |state|
        link_item(t("decisions.action.#{state}"),
                  new_motion_decision_path(resource.edge, state: state),
                  fa: decision_icon(Decision.new(state: state)))
      end
    else
      items = [link_item(t('decisions.action.forwarded'),
                         new_motion_decision_path(resource.edge, state: 'forwarded'),
                         fa: decision_icon(Decision.new(state: 'forwarded')))]
    end

    {
      title: t('decisions.take_decision'),
      fa: 'fa-gavel',
      sections: [items: items],
      defaultAction: motion_decisions_path(resource.edge)
    }
  end

  def decision_path(decision)
    motion_decision_path(decision.decisionable, decision.step)
  end

  def decision_log_url(decision)
    motion_decision_log_path(decision.decisionable, decision.step)
  end

  def edit_decision_url(decision)
    edit_motion_decision_url(decision.decisionable, decision.step)
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
    [{disabled: true, value: 0, groupName: t('decisions.find_user_info')}] +
      forum.page.groups.map do |group|
        {
          value: group.id.to_s,
          groupId: group.id,
          groupName: group.display_name
        }
      end
  end
end
