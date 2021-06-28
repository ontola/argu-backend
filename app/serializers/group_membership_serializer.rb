# frozen_string_literal: true

class GroupMembershipSerializer < RecordSerializer
  include Parentable::Serializer
  has_one :group, predicate: NS.org[:memberOf]
  has_one :user, predicate: NS.org[:member]
end
