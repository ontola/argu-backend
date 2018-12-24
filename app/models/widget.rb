# frozen_string_literal: true

class Widget < ApplicationRecord
  extend UriTemplateHelper

  enhance Createable

  belongs_to :owner, polymorphic: true, primary_key: :uuid

  enum widget_type: {custom: 0, discussions: 1, deku: 2, new_motion: 3, new_question: 4}

  acts_as_list scope: :owner

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

  private

  def property_shape(iri, predicate)
    @property_shapes ||= {}
    @property_shapes[iri] ||=
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
          resource_iri: [[creative_work.iri, nil], [new_iri(owner, :questions), nil]]
        )
    end

    def show_includes
      super + [:resource_sequence]
    end
  end
end
