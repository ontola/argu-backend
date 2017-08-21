# frozen_string_literal: true
class EdgePolicy < EdgeTreePolicy
  def permitted_attributes
    attributes = super
    if %w(Motion Question).include?(record.owner_type) #&& (is_manager? || is_super_admin? || staff?)
      attributes.concat %i(id expires_at)
    end
    attributes.append(argu_publication_attributes: %i(id publish_type published_at)) if record.owner.is_publishable?
    attributes.append(placements_attributes: %i(id lat lon placement_type zoom_level _destroy))
    attributes
  end

  private

  def edgeable_record
    record.owner
  end
end
