# frozen_string_literal: true

class Phase < Edge
  enhance Attachable
  enhance BlogPostable
  enhance BudgetShoppable
  enhance Commentable
  enhance Contactable
  enhance Convertible
  enhance CoverPhotoable
  enhance Exportable
  enhance Feedable
  enhance Inviteable
  enhance Moveable
  enhance Placeable
  enhance Statable
  enhance Surveyable
  enhance Questionable
  enhance Motionable
  enhance Orderable
  include Edgeable::Content

  counter_cache true
  parentable :project

  property :time,
           :string,
           NS.argu[:time]
  property :resource_id,
           :linked_edge_id,
           NS.argu[:resource],
           association_class: 'Edge'
  accepts_nested_attributes_for :resource
  attr_reader :resource_type

  enum resource_type: {
    survey: 0,
    question: 1,
    motion: 2,
    topic: 3,
    budget_shop: 4,
    blog_post: 5,
    vocabulary: 6,
    dashboard: 7
  }

  validates :display_name, presence: true, length: {minimum: 4, maximum: 75}
  validates :description, length: {maximum: MAXIMUM_DESCRIPTION_LENGTH}
  validates :resource, presence: true

  def resource_type=(type)
    self.resource ||= resource_from_type(type) if type
  end

  private

  def resource_attributes
    {
      creator: creator,
      name: name,
      description: '[placeholder]',
      publisher: publisher
    }
  end

  def resource_from_type(type) # rubocop:disable Metrics/AbcSize
    klass = type.to_s.classify.constantize
    child = build_child(klass, user_context: UserContext.new(user: publisher, profile: creator))
    child.assign_attributes(**resource_attributes)
    if child.class.enhanced_with?(ActivePublishable)
      child.try(:argu_publication)&.draft = true
      child.try(:argu_publication)&.published_at = nil
    else
      child.is_published = true
    end
    child.url = SecureRandom.send(:choose, [*'A'..'Z', *'a'..'z'], 16) if child.is_a?(ContainerNode)
    child
  end
end
