# frozen_string_literal: true

# Helper methods for decisions
module DecisionsHelper
  # @param [Decision] decision
  # @param [Boolean] create_link Set to true to link the name to the user's Profile
  # @return [String]
  def assigned_name(decision, create_link)
    if decision.user_id.present?
      user =
        if create_link
          link_to(decision.user.profile.display_name, user_path(decision.user))
        else
          decision.user.profile.display_name
        end
      "#{user} (#{decision.group.name_singular})"
    else
      decision.group.display_name
    end
  end

  # @param [ActiveRecord::Base] resource An ActiveRecord with has_many :decisions
  # @return [Hash]
  def decision_items(resource)
    if policy(resource.last_decision).is_actor?
      items = Decision.actioned_keys.map do |state|
        link_item(t("decisions.action.#{state}"),
                  edit_decision_path(resource.last_decision, state: state),
                  fa: decision_icon(Decision.new(state: state)))
      end
    else
      items = [link_item(t('decisions.action.forwarded'),
                         edit_decision_path(resource.last_decision, state: 'forwarded'),
                         fa: decision_icon(Decision.new(state: 'forwarded')))]
    end

    {
      title: t('decisions.take_decision'),
      fa: 'fa-gavel',
      sections: [items: items],
      defaultAction: motion_decisions_path(resource)
    }
  end

  # @return [String]
  def decision_state(decision)
    if decision.forwarded? && decision.forwarded_to.persisted?
      t('decisions.forwarded_to', to: assigned_name(decision.forwarded_to, false))
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
