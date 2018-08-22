# frozen_string_literal: true

require 'types/uri_type'

class Widget < ApplicationRecord
  extend UriTemplateHelper

  belongs_to :owner, polymorphic: true, primary_key: :uuid

  enum widget_type: {custom: 0, discussions: 1}
  attribute :resource_iri, URIType.new

  acts_as_list scope: :owner

  def label
    label_translation ? I18n.t(super) : super
  end

  class << self
    def create_discussions(owner)
      discussions
        .create(
          owner: owner,
          resource_iri: collection_iri(self, :discussions),
          label: 'discussions.plural',
          label_translation: true,
          body: '',
          size: 3
        )
    end
  end
end
