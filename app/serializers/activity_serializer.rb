# frozen_string_literal: true

class ActivitySerializer < RecordSerializer
  extend ActivityHelper

  attribute :published, predicate: NS::AS[:published] do |object|
    object.trackable.try(:published_at)
  end
  attribute :updated, predicate: NS::AS[:updated] do |object|
    object.trackable&.updated_at
  end
  attribute :comment, predicate: NS::SCHEMA[:text]
  attribute :notify, predicate: NS::ARGU[:sendNotifications], datatype: NS::XSD[:boolean]

  has_one :forum
  has_one :owner, predicate: NS::AS[:actor]
  has_one :recipient, predicate: NS::AS[:target]
  has_one :trackable, predicate: NS::AS[:object]

  attribute :display_name, predicate: NS::SCHEMA[:name] do |object, params|
    activity_string_for(object, params[:user], render: :template)
  end
end
