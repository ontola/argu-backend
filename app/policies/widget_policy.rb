# frozen_string_literal: true

class WidgetPolicy < EdgeTreePolicy
  class Scope < Scope
    def resolve
      return scope.none if user.nil?

      filter_granted_edges(scope)
    end

    private

    def filter_granted_edges(scope)
      return scope if staff?

      scope
        .joins(:owner)
        .with(granted_paths(show_only: false))
        .joins(granted_path_action_join(Widget.arel_table))
    end
  end

  permit_attributes %i[resource_iri raw_resource_iri size position widget_type permitted_action_title view]

  def create?
    return false unless administrator? || staff? || service?
    return forbid_wrong_tier unless feature_enabled?(:widgets)

    true
  end

  def update?
    return false unless administrator? || staff? || service?
    return forbid_wrong_tier unless feature_enabled?(:widgets)

    true
  end

  delegate :show?, to: :edgeable_policy
end
