# frozen_string_literal: true

class Widget < ApplicationRecord # rubocop:disable Metrics/ClassLength
  extend UriTemplateHelper
  include Parentable

  enhance LinkedRails::Enhancements::Createable

  belongs_to :owner, polymorphic: true, primary_key: :uuid
  belongs_to :primary_resource, class_name: 'Edge', primary_key: :uuid
  belongs_to :permitted_action

  enum widget_type: {
    custom: 0, discussions: 1, deku: 2, new_motion: 3, new_question: 4, overview: 5, blog_posts: 6, new_topic: 7
  }

  acts_as_list scope: :owner

  parentable :page, :container_node

  def edgeable_record
    @edgeable_record ||= owner
  end

  def property_shapes
    @property_shapes || {}
  end

  def replace_path(old, new)
    update(resource_iri: resource_iri.map { |iri, predicate| [iri.sub("#{old}/", "#{new}/"), predicate] })
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

  private

  def property_shape(iri, predicate)
    @property_shapes ||= {}
    @property_shapes[[iri, predicate]] ||=
      LinkedRails::PropertyQuery.new(
        target_node: RDF::DynamicURI(iri),
        path: RDF::DynamicURI(predicate)
      )
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
          primary_resource: owner,
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
          primary_resource: owner,
          resource_iri: [[discussions_iri, nil]],
          size: 3
        )
    end

    def create_new_motion(owner)
      creative_work =
        CreativeWork.create!(
          parent: owner,
          creator: Profile.service,
          publisher: User.service,
          creative_work_type: :new_motion,
          display_name: I18n.t('motions.call_to_action.title'),
          description: I18n.t('motions.call_to_action.body'),
          url_path: new_iri_path(owner, :motions)
        )
      new_motion
        .create(
          owner: owner,
          permitted_action: PermittedAction.find_by!(title: 'motion_create'),
          primary_resource: owner,
          resource_iri: [[creative_work.iri, nil], [new_iri(owner, :motions), nil]]
        )
    end

    def create_new_question(owner)
      creative_work =
        CreativeWork.create!(
          parent: owner,
          creator: Profile.service,
          publisher: User.service,
          creative_work_type: :new_question,
          display_name: I18n.t('questions.call_to_action.title'),
          description: I18n.t('questions.call_to_action.body'),
          url_path: new_iri_path(owner, :questions)
        )
      new_question
        .create(
          owner: owner,
          primary_resource: owner,
          permitted_action: PermittedAction.find_by!(title: 'question_create'),
          resource_iri: [[creative_work.iri, nil], [new_iri(owner, :questions), nil]]
        )
    end

    def create_new_topic(owner)
      creative_work =
        CreativeWork.create!(
          parent: owner,
          creator: Profile.service,
          publisher: User.service,
          creative_work_type: :new_topic,
          display_name: I18n.t('topics.call_to_action.title'),
          description: I18n.t('topics.call_to_action.body'),
          url_path: new_iri_path(owner, :topics)
        )
      new_topic
        .create(
          owner: owner,
          primary_resource: owner,
          permitted_action: PermittedAction.find_by!(title: 'topic_create'),
          resource_iri: [[creative_work.iri, nil], [new_iri(owner, :topics), nil]]
        )
    end

    def preview_includes
      super + %i[resource_sequence property_shapes]
    end
  end
end
