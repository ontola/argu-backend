# frozen_string_literal: true

class NotificationSerializer < RecordSerializer
  include Rails.application.routes.url_helpers
  include Actionable::Serializer
  include DecisionsHelper
  include_actions

  attribute :url_object, key: :target, predicate: NS::SCHEMA[:target]
  attribute :read_at, predicate: NS::SCHEMA[:dateRead]
  attribute :unread, predicate: NS::ARGU[:unread] do
    RDF::Literal.new(object.read_at.blank?)
  end

  has_one :creator, predicate: NS::SCHEMA[:creator] do
    object.activity.owner
  end
end
