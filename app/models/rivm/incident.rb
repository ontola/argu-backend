# frozen_string_literal: true

class Incident < Edge
  include Edgeable::Content
  enhance Attachable
  enhance Scenariable
  enhance LinkedRails::Enhancements::Tableable

  with_columns default: [
    NS::SCHEMA[:name],
    NS::ARGU[:scenariosCount]
  ]

  parentable :risk
  validates :description, length: {maximum: MAXIMUM_DESCRIPTION_LENGTH}
  validates :display_name, presence: true, length: {maximum: 110}

  class << self
    def iri_namespace
      NS::RIVM
    end
  end
end
