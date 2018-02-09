# frozen_string_literal: true

class EdgePolicy < EdgeablePolicy
  class Scope < Scope
    def resolve
      scope
        .where("edges.path ? #{Edge.path_array(granted_edges_within_tree || user.profile.granted_edges)}")
        .published
        .untrashed
    end
  end

  def permitted_attributes
    attributes = super
    if %w[Motion Question].include?(record.owner_type) && (moderator? || administrator? || staff?)
      attributes.concat %i[id expires_at]
    end
    attributes.append(argu_publication_attributes: argu_publication_attributes) if record.owner.is_publishable?
    attributes.append(placements_attributes: %i[id lat lon placement_type zoom_level _destroy])
    attributes
  end

  private

  def class_name
    record.owner_type
  end

  def edge
    record
  end

  def argu_publication_attributes
    argu_publication_attributes = %i[id draft]
    argu_publication_attributes.append(:published_at) if moderator? || administrator? || staff?
    argu_publication_attributes
  end
end
