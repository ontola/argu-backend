# frozen_string_literal: true

require 'types/uri_type'

class Widget < ApplicationRecord
  belongs_to :owner, polymorphic: true

  enum widget_type: {custom: 0, motions: 1, questions: 2}
  attribute :resource_iri, URIType.new

  acts_as_list scope: :owner

  def label
    label_translation ? I18n.t(super) : super
  end
end
