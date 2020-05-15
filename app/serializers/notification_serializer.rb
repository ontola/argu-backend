# frozen_string_literal: true

class NotificationSerializer < RecordSerializer
  attribute :url_object, predicate: NS::SCHEMA[:target]
  attribute :read_at, predicate: NS::SCHEMA[:dateRead]
  attribute :unread, predicate: NS::ARGU[:unread], &:unread

  has_one :creator, predicate: NS::SCHEMA[:creator] do |object|
    object.activity&.owner
  end
end
