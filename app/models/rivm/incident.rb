# frozen_string_literal: true

class Incident < Edge
  include Edgeable::Content
  enhance Attachable
  enhance Scenariable

  with_columns default: [
    NS.schema.name,
    NS.argu[:scenariosCount]
  ]

  validates :description, length: {maximum: MAXIMUM_DESCRIPTION_LENGTH}
  validates :display_name, presence: true, length: {maximum: 110}

  class << self
    def iri_namespace
      NS.rivm
    end

    def save_as_draft?(_parent)
      true
    end
  end
end
