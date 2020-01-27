# frozen_string_literal: true

class Widget < ApplicationRecord # rubocop:disable Metrics/ClassLength
  extend UriTemplateHelper
  include Parentable

  enhance LinkedRails::Enhancements::Actionable
  enhance LinkedRails::Enhancements::Creatable
  enhance LinkedRails::Enhancements::Updatable
  enhance LinkedRails::Enhancements::Destroyable
  enhance LinkedRails::Enhancements::Tableable

  belongs_to :owner, polymorphic: true, primary_key: :uuid
  belongs_to :permitted_action
  belongs_to :root, primary_key: :uuid, class_name: 'Edge'
  acts_as_tenant :root, class_name: 'Edge', primary_key: :uuid

  before_create :set_root

  enum widget_type: {
    custom: 0, discussions: 1, deku: 2, new_motion: 3, new_question: 4, blog_posts: 6, new_topic: 7
  }
  enum view: {full_view: 0, compact_view: 1, preview_view: 2}
  self.default_sortings = [{key: NS::ARGU[:order], direction: :asc}]

  with_columns default: [
    NS::ARGU[:rawResource],
    NS::ONTOLA[:widgetSize],
    NS::ARGU[:order],
    NS::ARGU[:view],
    NS::ONTOLA[:updateAction],
    NS::ONTOLA[:destroyAction]
  ]

  acts_as_list scope: :owner

  parentable :page, :container_node, :phase

  def edgeable_record
    @edgeable_record ||= owner
  end

  def property_shapes
    @property_shapes || {}
  end

  def raw_resource_iri
    resource_iri&.map { |iri| iri.compact.join(',') }&.join("\n")
  end

  def raw_resource_iri=(value)
    self.resource_iri = value.split("\n").map { |line| line.split(',') }
  end

  def resource_sequence
    @resource_sequence ||=
      LinkedRails::Sequence.new(
        resource_iri
          .map { |iri, predicate| predicate.present? ? property_shape(iri, predicate).iri : RDF::DynamicURI(iri) }
      )
  end

  def parent
    edgeable_record
  end

  def permitted_action_title=(title)
    self.permitted_action = PermittedAction.find_by(title: title)
  end

  def topology
    return NS::ARGU[:grid] if preview_view?
    return NS::ARGU[:container] if compact_view?

    NS::ARGU[:fullResource]
  end

  private

  def property_shape(iri, predicate)
    @property_shapes ||= {}
    @property_shapes[[iri, predicate]] ||=
      LinkedRails::PropertyQuery.new(
        target_node: RDF::DynamicURI(iri),
        path: RDF::DynamicURI(predicate)
      )
  end

  def set_root
    self.root_id ||= owner.root_id
  end

  class << self
    def iri
      NS::ONTOLA[:Widget]
    end

    def create_blog_posts(owner)
      blog_posts_iri = collection_iri(owner, :blog_posts, type: :infinite)
      discussions
        .create(
          owner: owner,
          permitted_action: PermittedAction.find_by!(title: 'blog_post_show'),
          resource_iri: [[blog_posts_iri, nil]],
          size: 3
        )
    end

    def create_discussions(owner)
      discussions_iri = collection_iri(owner, :discussions, display: :grid, type: :infinite)
      discussions
        .create(
          owner: owner,
          permitted_action: PermittedAction.find_by!(title: 'motion_show'),
          resource_iri: [[discussions_iri, nil]],
          size: 3
        )
    end

    def create_new_motion(owner)
      custom_action = CustomAction.create!(
        is_published: true,
        creator: Profile.service,
        publisher: User.service,
        parent: owner,
        href: new_iri(owner, :motions),
        label_translation: true,
        label: 'motions.call_to_action.title',
        description_translation: true,
        description: 'motions.call_to_action.body',
        submit_label_translation: true,
        submit_label: 'motions.type_new'
      )
      new_motion
        .preview_view
        .create(
          owner: owner,
          permitted_action: PermittedAction.find_by!(title: 'motion_create'),
          resource_iri: [[custom_action.iri, nil]]
        )
    end

    def create_new_question(owner)
      custom_action = CustomAction.create!(
        is_published: true,
        creator: Profile.service,
        publisher: User.service,
        parent: owner,
        href: new_iri(owner, :questions),
        label_translation: true,
        label: 'questions.call_to_action.title',
        description_translation: true,
        description: 'questions.call_to_action.body',
        submit_label_translation: true,
        submit_label: 'questions.type_new'
      )
      new_question
        .preview_view
        .create(
          owner: owner,
          permitted_action: PermittedAction.find_by!(title: 'question_create'),
          resource_iri: [[custom_action.iri, nil]]
        )
    end

    def create_new_topic(owner)
      custom_action = CustomAction.create!(
        is_published: true,
        creator: Profile.service,
        publisher: User.service,
        parent: owner,
        href: new_iri(owner, :topics),
        label_translation: true,
        label: 'topics.call_to_action.title',
        description_translation: true,
        description: 'topics.call_to_action.body',
        submit_label_translation: true,
        submit_label: 'topics.type_new'
      )
      new_topic
        .preview_view
        .create(
          owner: owner,
          permitted_action: PermittedAction.find_by!(title: 'topic_create'),
          resource_iri: [[custom_action.iri, nil]]
        )
    end

    def preview_includes
      super + %i[resource_sequence property_shapes]
    end
  end
end
