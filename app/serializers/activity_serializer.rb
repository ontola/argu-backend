# frozen_string_literal: true

class ActivitySerializer < RecordSerializer
  include ActivityHelper

  attribute :id
  attribute :action_status

  has_one :forum
  has_one :owner
  has_one :recipient
  has_one :trackable, predicate: NS::SCHEMA[:about]

  def action_status
    'CompletedActionStatus'
  end

  def display_name
    activity_string_for(object, user_context.user, false)
  end
end
