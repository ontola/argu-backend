# frozen_string_literal: true

class ActivitySerializer < RecordSerializer
  include ActivityHelper
  include MarkdownHelper
  ACTION_TYPE = {
    create: NS::AS[:Create],
    publish: NS::ARGU[:Publish],
    update: NS::AS[:Update],
    destroy: NS::AS[:Delete],
    trash: NS::AS[:Remove],
    approved: NS::AS[:Accept],
    rejected: NS::AS[:Reject],
    forwarded: NS::ARGU[:Forward],
    untrash: NS::AS[:Add],
    convert: NS::ARGU[:Convert]

  }.freeze

  attribute :published, predicate: NS::AS[:published]
  attribute :updated, predicate: NS::AS[:updated]
  attribute :summary, predicate: NS::AS[:summary]
  attribute :action_status

  has_one :forum
  has_one :owner, predicate: NS::AS[:actor]
  has_one :recipient, predicate: NS::AS[:target]
  has_one :trackable, predicate: NS::AS[:object]

  def action_status
    'CompletedActionStatus'
  end

  def display_name
    activity_string_for(object, scope.user, false)
  end

  def published
    object.trackable.try(:published_at)
  end

  def summary
    markdown_to_html(activity_string_for(object, scope.user, true), no_paragraph: true)
  end

  def type
    ACTION_TYPE[object.action] || NS::AS[:Activity]
  end

  def updated
    object.trackable.updated_at
  end
end
