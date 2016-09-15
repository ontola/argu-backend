class GroupMembership < ApplicationRecord
  include Parentable

  belongs_to :group
  belongs_to :member,
             inverse_of: :group_memberships,
             class_name: 'Profile'
  belongs_to :profile
  has_one :page,
          through: :group
  has_one :user,
          through: :member,
          source: :profileable,
          source_type: :User
  has_many :grants, through: :group
  before_create :create_membership_before_managership
  before_destroy :remove_managerships_on_forum_leave

  validates :group_id, :member_id, presence: true

  paginates_per 30
  parentable :group

  def publisher
    edge.user
  end

  private

  def create_membership_before_managership
    grant = group.grants.manager.first
    if grant.present? && member.grants.member.where(edge: grant.edge).empty?
      Edge.create!(
        parent: group.edge,
        user: publisher,
        owner: member.group_memberships.new(
          group: grant.edge.owner.members_group,
          member: member,
          profile: profile))
    end
  end

  def remove_managerships_on_forum_leave
    grant = group.grants.member.first
    if grant.present?
      member
        .group_memberships
        .joins(:grants)
        .where(grants: {edge: grant.edge, role: Grant.roles[:manager]})
        .destroy_all
    end
  end
end
