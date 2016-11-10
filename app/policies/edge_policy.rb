# frozen_string_literal: true
class EdgePolicy < EdgeTreePolicy
  alias edge record

  def permitted_attributes
    attributes = super
    attributes.concat %i(id is_trashed trashed_at) if record.owner.is_trashable?
    if %w(Motion Question).include?(record.owner_type) && (is_manager? || is_super_admin? || staff?)
      attributes.concat %i(id expires_at)
    end
    attributes.append(argu_publication_attributes: %i(id publish_type published_at)) if record.owner.is_publishable?
    attributes
  end
end
