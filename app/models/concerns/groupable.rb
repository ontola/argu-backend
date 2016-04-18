module Groupable
  extend ActiveSupport::Concern

  included do
    has_many :groups, through: :edge
    has_one :managers_group, -> { where(shortname: 'managers') }, through: :edge, class_name: 'Group'
    has_many :managerships, class_name: 'GroupMembership', through: :managers_group, source: :group_memberships
    has_many :managers, through: :managerships, source: :member
    has_one :members_group, -> { where(shortname: 'members') }, through: :edge, class_name: 'Group'
    has_many :memberships, class_name: 'GroupMembership', through: :members_group, source: :group_memberships
    has_many :members, through: :memberships, source: :member
    accepts_nested_attributes_for :memberships
  end
end
