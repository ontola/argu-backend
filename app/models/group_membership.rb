class GroupMembership < ActiveRecord::Base
  include ArguBase

  belongs_to :group
  belongs_to :member,
             inverse_of: :group_memberships,
             class_name: 'Profile'
  belongs_to :profile
  has_one :edge,
          through: :group
  has_one :user,
          through: :member,
          source: :profileable,
          source_type: :User
  scope :for_forums, -> {where(edges: {owner_type: 'Forum'})}
  scope :for_pages, -> {where(edges: {owner_type: 'Page'})}
  before_create :create_membership_before_managership
  before_destroy :remove_managerships_on_forum_leave

  validates :group_id, :member_id, presence: true

  delegate :owner, to: :edge

  private

  def create_membership_before_managership
    if group.shortname == 'managers' && member.memberships.where(groups: {edge_id: edge.id}).empty?
      member.group_memberships.create(group: edge.members_group, member: member, profile: profile)
    end
  end

  def remove_managerships_on_forum_leave
    member.managerships.where(groups: {edge_id: edge.id}).destroy_all if group.shortname == 'members'
  end
end
