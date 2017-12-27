# frozen_string_literal: true

class GroupMembershipSerializer < BaseSerializer
  include Parentable::Serializer
  has_one :group
  has_one :user
end
