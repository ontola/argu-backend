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

  paginates_per 15

  before_create :set_default_decision_group

  def default_decision_user
    nil
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
