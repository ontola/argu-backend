# frozen_string_literal: true

# Helper methods for decisions
module DecisionsHelper
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
                    edit_decision_path(resource.decisions.last),
                    fa: 'pencil')
        ]
      elsif resource.assigned_to_user?(current_user)
        Decision.actioned_keys.map do |state|
          link_item(t("decisions.action.#{state}"),
                    new_decision_path(resource.edge, state: state),
                    fa: decision_icon(Decision.new(state: state)))
        end
      else
        [
          link_item(t('decisions.action.forwarded'),
                    new_decision_path(resource.edge, state: 'forwarded'),
                    fa: decision_icon(Decision.new(state: 'forwarded')))
        ]
      end

    {
      title: t('decisions.take_decision'),
      fa: 'fa-gavel',
      sections: [items: items],
      defaultAction: motion_decisions_path(resource.edge)
    }
  end

  def decisionable_path(edge)
    url_for(controller: "/#{edge.owner_type.tableize}", id: edge.id, action: :show)
  end

  def decision_path(decision)
    "#{decisionable_path(decision.edge.parent)}/decision/#{decision.step}"
  end
  alias decision_url decision_path

  def edit_decision_path(decision)
    "#{decisionable_path(decision.edge.parent)}/decision/#{decision.step}/edit"
  end
  alias edit_decision_url edit_decision_path

  def new_decision_path(edge, opts = {})
    path = "#{decisionable_path(edge)}/decision/new"
    opts.present? ? [path, opts.to_param].join('?') : path
  end
  alias new_decision_url new_decision_path

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
