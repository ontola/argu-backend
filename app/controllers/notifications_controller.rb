# frozen_string_literal: true

class NotificationsController < AuthorizedController
  skip_before_action :authorize_action, only: %i[index read_all]
  skip_after_action :verify_authorized, only: %i[index read_all]

  after_action :update_viewed_time

  has_resource_update_action(
    action_path: :read,
    image: 'fa-check',
    one_click: true,
    predicate: NS.ontola[:readAction],
    type: NS.schema.ReadAction
  )
  has_collection_action(
    :read_all,
    favorite: true,
    http_method: :put,
    image: 'fa-check',
    one_click: true
  )

  private

  def read_all_execute
    # rubocop:disable Rails/SkipsModelValidations
    policy_scope(Notification)
      .where(read_at: nil, permanent: false)
      .update_all(read_at: Time.current)
    # rubocop:enable Rails/SkipsModelValidations
  end

  def read_all_success
    respond_with_resource(
      meta: read_all_meta
    )
  end

  def read_all_meta
    update_meta + [
      [NS.sp.Variable, NS.argu[:unread], true, delta_iri(:remove)]
    ]
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
