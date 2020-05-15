# frozen_string_literal: true

class GroupMembershipSerializer < RecordSerializer
  include Parentable::Serializer
  has_one :group, predicate: NS::ORG[:memberOf]
  has_one :user, predicate: NS::ORG[:member]
end
