# frozen_string_literal: true

class PublicationPolicy < EdgeTreePolicy
  delegate :show?, to: :edgeable_policy

  def permitted_attribute_names
    attributes = super
    attributes.concat %i[id published_at]
    unless record.publishable&.is_published? && !new_record?
      attributes.concat %i[draft] if new_record?
    end
    attributes
  end
end
