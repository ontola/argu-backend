# frozen_string_literal: true

class Forum < ContainerNode
  enhance BlogPostable
  enhance Discussable
  enhance Inviteable
  enhance Motionable
  enhance Questionable
  enhance Topicable

  property :default_decision_group_id, :integer, NS::ARGU[:defaultDecisionGroupId]

  belongs_to :default_decision_group, class_name: 'Group', foreign_key_property: :default_decision_group_id

  self.default_widgets = %i[new_motion new_question new_topic discussions]

  paginates_per 30

  before_create :set_default_decision_group

  scope :top_public_forums, lambda { |limit = 10|
    public_forums.first(limit)
  }
  scope :public_forums, lambda {
    joins(:grants)
      .where(discoverable: true, grants: {group_id: Group::PUBLIC_ID})
      .order('edges.follows_count DESC')
  }

  def default_decision_user
    nil
  end

  # @return [Forum] based on the `:default_forum` {Setting}, if not present,
  # the first Forum where {Forum#discoverable} is true and a {Grant} for the public {Group} is present
  def self.first_public
    if (setting = Setting.get(:default_forum))
      forum = Edge.find_by!(uuid: setting)
    end
    forum || Forum.public_forums.first
  end

  def self.policy_class
    ForumPolicy
  end

  private

  def set_default_decision_group
    self.default_decision_group =
      parent.grants.joins(:group).find_by(grant_set: GrantSet.administrator, groups: {deletable: false}).group
  end
end
