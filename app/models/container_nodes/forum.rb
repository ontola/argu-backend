# frozen_string_literal: true

class Forum < ContainerNode
  enhance BlogPostable
  enhance Discussable
  enhance Inviteable
  enhance Motionable
  enhance Questionable
  enhance Pollable
  enhance SwipeToolable
  enhance Topicable

  has_one :primary_container_node_of,
          primary_key_property: :primary_container_node_id,
          class_name: 'Page',
          dependent: :nullify

  self.default_widgets = %i[new_motion new_question new_topic discussions]

  paginates_per 15

  def self.policy_class
    ForumPolicy
  end
end
