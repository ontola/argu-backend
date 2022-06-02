# frozen_string_literal: true

class WidgetPolicy < EdgeTreePolicy
  class Scope < Scope
    def resolve
      return scope.none if user.nil?

      scope
        .joins(:owner)
        .with(granted_paths(show_only: false))
        .joins(granted_path_action_join(Widget.arel_table))
    end
  end

  permit_attributes %i[resource_iri raw_resource_iri size position widget_type permitted_action_title view]

  def create?
    staff? || service?
  end

  def update?
    staff? || service?
  end

  delegate :show?, to: :edgeable_policy
end
