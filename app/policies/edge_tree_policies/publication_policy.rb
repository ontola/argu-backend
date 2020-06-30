# frozen_string_literal: true

class PublicationPolicy < EdgeTreePolicy
  delegate :show?, to: :edgeable_policy

  permit_attributes %i[published_at]
  permit_attributes %i[draft], has_properties: {published_at: false}
end
