# frozen_string_literal: true

class NotificationSerializer < RecordSerializer
  attribute :url_object, predicate: NS.schema.target
  attribute :read_at, predicate: NS.schema.dateRead
  attribute :unread, predicate: NS.argu[:unread], &:unread

  has_one :creator, predicate: NS.schema.creator do |object|
    object.activity&.owner
  end
end
