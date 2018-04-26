# frozen_string_literal: true

module Actions
  class NotificationActions < Base
    define_actions %i[read]

    private

    def read_action
      action_item(
        :read,
        target: read_entrypoint,
        result: Notification,
        type: NS::SCHEMA[:ReadAction],
        policy: :read?
      )
    end

    def read_entrypoint
      entry_point_item(
        :read,
        image: 'fa-check',
        url: RDF::URI(notification_url(resource, type: :infinite)),
        http_method: :put
      )
    end
  end
end
