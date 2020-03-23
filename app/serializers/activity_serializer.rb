# frozen_string_literal: true

class ActivitySerializer < RecordSerializer
  include ActivityHelper
  ACTION_TYPE = {
    create: NS::AS[:Create],
    publish: NS::ARGU[:PublishActivity],
    update: NS::AS[:Update],
    destroy: NS::AS[:Delete],
    trash: NS::AS[:Remove],
    approved: NS::AS[:Accept],
    rejected: NS::AS[:Reject],
    forwarded: NS::ARGU[:ForwardActivity],
    untrash: NS::AS[:Add],
    convert: NS::ARGU[:ConvertActivity]
  }.freeze

  attribute :published, predicate: NS::AS[:published]
  attribute :updated, predicate: NS::AS[:updated]
  attribute :action_status
  attribute :comment, predicate: NS::SCHEMA[:text]
  attribute :notify, predicate: NS::ARGU[:sendNotifications], datatype: NS::XSD[:boolean]

  has_one :forum
  has_one :owner, predicate: NS::AS[:actor]
  has_one :recipient, predicate: NS::AS[:target]
  has_one :trackable, predicate: NS::AS[:object]

  def action_status
    'CompletedActionStatus'
  end

  def display_name
    activity_string_for(object, scope.user, render: :template)
  end

  def published
    object.trackable.try(:published_at)
  end

  def type
    ACTION_TYPE[object.action.to_sym] || NS::AS[:Activity]
  end

  def updated
    object.trackable&.updated_at
  end
end
