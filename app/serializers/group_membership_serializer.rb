# frozen_string_literal: true

class GroupMembershipSerializer < RecordSerializer
  include Parentable::Serializer

  def self.administrator(_object, opts)
    return false if opts[:scope]&.user.nil?

    opts[:scope].user.profile.groups.admin.any? || opts[:scope].user.staff?
  end

  has_one :group, predicate: NS.org[:memberOf]
  has_one :user, predicate: NS.org[:member]
  attribute :email, predicate: NS.schema.email, if: method(:administrator)
end
