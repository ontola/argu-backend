# frozen_string_literal: true

class EdgePolicy < EdgeTreePolicy
  class Scope < Scope
    def resolve
      return scope.published.untrashed if staff?
      scope
        .where("edges.path ? #{Edge.path_array(granted_edges_within_tree || user.profile.granted_edges)}")
        .published
        .untrashed
    end
  end

  alias edge record

  def permitted_attributes
    attributes = super
    if %w(Motion Question).include?(record.owner_type) && (is_manager? || is_super_admin? || staff?)
      attributes.concat %i(id expires_at)
    end
    if record.owner.is_publishable?
      argu_publication_attributes = %i(id draft)
      argu_publication_attributes.append(:published_at) if is_manager? || is_super_admin? || staff?
      attributes.append(argu_publication_attributes: argu_publication_attributes)
    end
    attributes.append(placements_attributes: %i(id lat lon placement_type zoom_level _destroy))
    attributes
  end
end
