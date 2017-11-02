# frozen_string_literal: true

class NotificationSerializer < RecordSerializer
  include Rails.application.routes.url_helpers
  include DecisionsHelper

  attribute :url_object, key: :target, predicate: NS::SCHEMA[:target]
  attribute :read_at, predicate: NS::SCHEMA[:dateRead]
  attribute :unread, predicate: NS::ARGU[:unread] do
    object.read_at.blank?
  end

  has_one :creator, predicate: NS::SCHEMA[:creator] do
    object.activity.owner
  end
end
