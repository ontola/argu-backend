# frozen_string_literal: true

class Widget < ApplicationRecord # rubocop:disable Metrics/ClassLength
  extend UriTemplateHelper
  include Parentable

  enhance Createable

  belongs_to :owner, polymorphic: true, primary_key: :uuid
  belongs_to :primary_resource, class_name: 'Edge', primary_key: :uuid
  belongs_to :permitted_action

  enum widget_type: {custom: 0, discussions: 1, deku: 2, new_motion: 3, new_question: 4, overview: 5}

  acts_as_list scope: :owner

  parentable :page, :forum

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
      RDF::Sequence.new(
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
      RailsLD::PropertyQuery.new(
        target_node: RDF::DynamicURI(iri),
        path: RDF::DynamicURI(predicate)
      )
  end

  class << self
    def create_discussions(owner)
      discussions_iri = collection_iri(owner, :discussions, display: :grid, type: :infinite)
      discussions
        .create(
          owner: owner,
          permitted_action: PermittedAction.find_by(title: 'motion_show'),
          primary_resource: owner,
          resource_iri: [[discussions_iri, NS::AS[:name]], [discussions_iri, nil]],
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
          description: I18n.t('motions.call_to_action.body')
        )
      new_motion
        .create(
          owner: owner,
          permitted_action: PermittedAction.find_by(title: 'motion_create'),
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
          description: I18n.t('questions.call_to_action.body')
        )
      new_question
        .create(
          owner: owner,
          primary_resource: owner,
          permitted_action: PermittedAction.find_by(title: 'question_create'),
          resource_iri: [[creative_work.iri, nil], [new_iri(owner, :questions), nil]]
        )
    end

    def create_overview(owner)
      overview
        .create(
          owner: owner.parent,
          permitted_action: PermittedAction.find_by(title: 'forum_show'),
          primary_resource: owner,
          resource_iri: [
            [owner.iri, NS::SCHEMA[:name]],
            [collection_iri(owner, :discussions, display: :card, page_size: 5), nil]
          ]
        )
    end

    def preview_includes
      super + %i[resource_sequence property_shapes]
    end
  end
end
