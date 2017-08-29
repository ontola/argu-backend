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
