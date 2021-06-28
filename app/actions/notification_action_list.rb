# frozen_string_literal: true

class NotificationActionList < ApplicationActionList
  has_resource_action(
    :read,
    result: Notification,
    type: NS.schema.ReadAction,
    policy: :read?,
    image: 'fa-check',
    url: -> { resource.iri },
    http_method: :put
  )
end
