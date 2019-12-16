# frozen_string_literal: true

class WidgetPolicy < EdgeTreePolicy
  class Scope < Scope
    def resolve
      return if user.nil?
      scope
        .joins("JOIN edges ON edges.uuid = widgets.owner_id AND widgets.owner_type = 'Edge'")
        .with(granted_paths(show_only: false))
        .where("(#{path_filter}) @> edges.path")
    end

    private

    def path_filter
      granted_paths_table
        .where(granted_paths_table[:id].eq(widgets_table[:permitted_action_id]))
        .project('array_agg(path)').to_sql
    end
  end

  def permitted_attribute_names
    attributes = super
    attributes.concat %i[resource_iri raw_resource_iri size position widget_type permitted_action_title]
    attributes
  end

  def create?
    staff? || service?
  end

  def update?
    staff? || service?
  end

  def show?
    edgeable_policy.show?
  end
end
