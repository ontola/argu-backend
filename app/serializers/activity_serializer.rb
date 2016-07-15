# frozen_string_literal: true
class ActivitySerializer < BaseSerializer
  attributes :id

  has_one :forum
  has_one :owner
  has_one :recipient
  has_one :trackable
end
