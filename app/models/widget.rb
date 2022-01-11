# frozen_string_literal: true

class Widget < ApplicationRecord # rubocop:disable Metrics/ClassLength
  extend URITemplateHelper
  include Parentable
  include Cacheable
  include Broadcastable
  collection_options(
    display: :table
  )

  enhance LinkedRails::Enhancements::Creatable
  enhance LinkedRails::Enhancements::Updatable
  enhance LinkedRails::Enhancements::Destroyable
  enhance Orderable

  belongs_to :owner, class_name: 'Edge', primary_key: :uuid
  belongs_to :permitted_action
  belongs_to :root, primary_key: :uuid, class_name: 'Edge'
  acts_as_tenant :root, class_name: 'Edge', primary_key: :uuid
  paginates_per 100

  before_create :set_root

  enum widget_type: {
    custom: 0, discussions: 1, deku: 2, new_motion: 3, new_question: 4, blog_posts: 6, new_topic: 7
  }
  enum view: {full_view: 0, compact_view: 1, preview_view: 2}

  with_columns default: [
    NS.argu[:order],
    NS.argu[:rawResource],
    NS.ontola[:widgetSize],
    NS.argu[:view],
    NS.ontola[:updateAction],
    NS.ontola[:destroyAction]
  ]

  acts_as_list scope: :owner

  parentable :page, :container_node, :phase

  def edgeable_record
    @edgeable_record ||= owner
  end

  def property_shapes
    resource_sequence

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
        (resource_iri || [])
          .map { |iri, predicate| predicate.present? ? property_shape(iri, predicate).iri : RDF::URI(iri) },
        scope: false
      )
  end

  def parent
    edgeable_record
  end

  def permitted_action_title=(title)
    self.permitted_action = PermittedAction.find_by(title: title)
  end

  def topology
    return NS.argu[:grid] if preview_view?
    return NS.argu[:container] if compact_view?

    NS.argu[:fullResource]
  end

  private

  def property_shape(iri, predicate)
    @property_shapes ||= {}
    @property_shapes[[iri, predicate]] ||=
      LinkedRails::PropertyQuery.new(
        target_node: RDF::URI(iri),
        path: RDF::URI(predicate)
      )
  end

  def set_root
    self.root_id ||= owner.root_id
  end

  class << self
    def attributes_for_new(opts)
      action = PermittedAction.find_by!(resource_type: opts[:parent].owner_type, action_name: :show) if opts[:parent]

      super.merge(
        owner: opts[:parent],
        permitted_action: action,
        widget_type: :custom
      )
    end

    def iri
      NS.ontola[:Widget]
    end

    def create_blog_posts(owner)
      blog_posts_iri = owner.collection_iri(:blog_posts, type: :infinite)
      Widget.create!(
        widget_type: :discussions,
        owner: owner,
        permitted_action: PermittedAction.find_by!(title: 'blog_post_show'),
        resource_iri: [[blog_posts_iri, nil]],
        size: 3
      )
    end

    def create_discussions(owner)
      discussions_iri = owner.collection_iri(:discussions, display: :grid, type: :infinite)
      Widget.create!(
        widget_type: :discussions,
        owner: owner,
        permitted_action: PermittedAction.find_by!(title: 'motion_show'),
        resource_iri: [[discussions_iri, nil]],
        size: 3
      )
    end

    def create_new_motion(owner) # rubocop:disable Metrics/MethodLength
      custom_action = CustomAction.create!(
        is_published: true,
        creator: Profile.service,
        publisher: User.service,
        parent: owner,
        href: new_iri(owner, :motions),
        label: 'motions.call_to_action.title',
        description: 'motions.call_to_action.body',
        submit_label: 'motions.type_new'
      )

      Widget.create!(
        widget_type: :new_motion,
        view: :preview_view,
        owner: owner,
        permitted_action: PermittedAction.find_by!(title: 'motion_create'),
        resource_iri: [[custom_action.iri(fragment: 'EntryPoint'), nil]]
      )
    end

    def create_new_question(owner) # rubocop:disable Metrics/MethodLength
      custom_action = CustomAction.create!(
        is_published: true,
        creator: Profile.service,
        publisher: User.service,
        parent: owner,
        href: new_iri(owner, :questions),
        label: 'questions.call_to_action.title',
        description: 'questions.call_to_action.body',
        submit_label: 'questions.type_new'
      )

      Widget.create!(
        widget_type: :new_question,
        view: :preview_view,
        owner: owner,
        permitted_action: PermittedAction.find_by!(title: 'question_create'),
        resource_iri: [[custom_action.iri(fragment: 'EntryPoint'), nil]]
      )
    end

    def create_new_topic(owner) # rubocop:disable Metrics/MethodLength
      custom_action = CustomAction.create!(
        is_published: true,
        creator: Profile.service,
        publisher: User.service,
        parent: owner,
        href: new_iri(owner, :topics),
        label: 'topics.call_to_action.title',
        description: 'topics.call_to_action.body',
        submit_label: 'topics.type_new'
      )

      Widget.create!(
        widget_type: :new_topic,
        view: :preview_view,
        owner: owner,
        permitted_action: PermittedAction.find_by!(title: 'topic_create'),
        resource_iri: [[custom_action.iri(fragment: 'EntryPoint'), nil]]
      )
    end

    def preview_includes
      super + %i[resource_sequence property_shapes]
    end
  end
end
