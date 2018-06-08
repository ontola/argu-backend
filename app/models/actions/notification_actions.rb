# frozen_string_literal: true

module Actions
  class NotificationActions < Base
    define_action(
      :read,
      result: Notification,
      type: NS::SCHEMA[:ReadAction],
      policy: :read?,
      image: 'fa-check',
      url: -> { resource.iri },
      http_method: :put
    )
  end
end
