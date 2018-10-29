# frozen_string_literal: true

class PublicationPolicy < EdgeTreePolicy
  def permitted_attribute_names
    attributes = super
    attributes.concat %i[id]
    unless record.publishable&.is_published? && !new_record?
      attributes.concat %i[draft] if new_record?
      attributes.concat %i[published_at] if moderator? || administrator? || staff?
    end
    attributes
  end
end
