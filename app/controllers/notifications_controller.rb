# frozen_string_literal: true

# @note: Common create ready
class NotificationsController < AuthorizedController
  include NotificationsHelper

  skip_before_action :authorize_action, only: :index

  after_action :update_viewed_time

  def show
    respond_to do |format|
      RDF_CONTENT_TYPES.each do |type|
        format.send(type) { render type => authenticated_resource, include: :operation }
      end
      format.all { redirect_to authenticated_resource.activity.trackable.iri }
    end
  end

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

  def index_collection
    @index_collection ||= ::Collection.new(
      collection_options.merge(
        association_class: Notification,
        default_type: :infinite,
        parent: nil
      )
    )
  end

  def index_meta # rubocop:disable Metrics/AbcSize
    m = []
    m <<
      if index_collection.is_a?(CollectionView)
        [
          index_collection.collection.iri,
          NS::AS[:page],
          index_collection.iri,
          delta_iri(:replace)
        ]
      else
        [
          index_collection.iri,
          NS::ARGU[:unreadCount],
          unread_notification_count,
          delta_iri(:replace)
        ]
      end
    m
  end

  def permit_params
    params.require(:notification).permit(*policy(@notification || Notification).permitted_attributes)
  end

  def update_execute
    n = authenticated_resource
    read_before = n.read_at.present?
    read_before || n.permanent? || n.update(read_at: Time.current)
  end

  def update_meta
    index_meta + super
  end

  def update_success_rdf
    respond_with_resource(resource: authenticated_resource, include: show_includes, meta: index_meta)
  end

  def update_failure
    head 400
  end

  def update_viewed_time
    current_user.update(notifications_viewed_at: Time.current) unless current_user.guest?
  end
end
