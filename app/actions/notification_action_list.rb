# frozen_string_literal: true

class NotificationActionList < ApplicationActionList
  has_action(
    :read,
    result: Notification,
    type: NS::SCHEMA[:ReadAction],
    policy: :read?,
    image: 'fa-check',
    url: -> { resource.iri },
    http_method: :put
  )
end
