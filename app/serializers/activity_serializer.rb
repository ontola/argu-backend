# frozen_string_literal: true

class ActivitySerializer < RecordSerializer
  extend ActivityHelper

  attribute :published, predicate: NS.as[:published] do |object|
    object.trackable.try(:published_at)
  end
  attribute :updated, predicate: NS.as[:updated] do |object|
    object.trackable&.updated_at
  end
  attribute :comment, predicate: NS.schema.text
  attribute :notify, predicate: NS.argu[:sendNotifications], datatype: NS.xsd.boolean

  has_one :owner, predicate: NS.as[:actor]
  has_one :recipient, predicate: NS.as[:target]
  has_one :trackable, predicate: NS.as[:object]

  attribute :display_name, predicate: NS.schema.name do |object, params|
    activity_string_for(object, params[:user], render: :template)
  end
end
