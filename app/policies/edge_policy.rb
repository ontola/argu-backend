# frozen_string_literal: true
class EdgePolicy < EdgeTreePolicy
  alias edge record

  def permitted_attributes
    attributes = super
    attributes.concat %i(id is_trashed trashed_at) if record.owner.is_trashable?
    if record.owner.is_publishable?
      publication_attributes = %i(id publish_type)
      publication_attributes << :published_at unless record.owner_type == 'Decision'
      attributes.append(argu_publication_attributes: publication_attributes)
    end
    attributes
  end
end
