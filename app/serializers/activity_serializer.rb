# frozen_string_literal: true

class ActivitySerializer < BaseSerializer
  attributes :id
  attribute :action_status

  has_one :forum
  has_one :owner
  has_one :recipient
  has_one :trackable

  def action_status
    'CompletedActionStatus'
  end
end
