# frozen_string_literal: true

class NotificationActions < ActionList
  cattr_accessor :defined_actions
  define_actions %i[read]

  private

  def read_action
    action_item(
      :read,
      target: read_entrypoint,
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
