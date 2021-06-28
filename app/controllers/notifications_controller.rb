# frozen_string_literal: true

# @note: Common create ready
class NotificationsController < AuthorizedController
  skip_before_action :authorize_action, only: :index

  after_action :update_viewed_time

  def read
    # rubocop:disable Rails/SkipsModelValidations
    if policy_scope(Notification)
         .where(read_at: nil, permanent: false)
         .update_all(read_at: Time.current)
      head 200
    else
      head 400
    end
    # rubocop:enable Rails/SkipsModelValidations
  end

  private

  def authorize_action
    return super unless action_name == 'read'

    authorize Notification, :read?
  end

  def update_execute
    n = authenticated_resource
    read_before = n.read_at.present?
    read_before || n.permanent? || n.update(read_at: Time.current)
  end

  def update_meta
    [
      RDF::Statement.new(
        current_actor.iri,
        NS.argu[:unreadCount],
        current_actor.unread_notification_count,
        graph_name: delta_iri(:replace)
      )
    ]
  end

  def update_success_rdf
    respond_with_resource(resource: authenticated_resource, include: show_includes, meta: update_meta)
  end

  def update_failure
    head 400
  end

  def update_viewed_time
    current_user.update(notifications_viewed_at: Time.current) unless current_user.guest?
  end
end
