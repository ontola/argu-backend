# frozen_string_literal: true

class Scenario < Edge
  include Edgeable::Content
  enhance Attachable
  enhance LinkedRails::Enhancements::Tableable
  with_columns default: [
    NS::SCHEMA[:name]
  ]

  parentable :incident
  counter_cache true
  validates :description, length: {maximum: MAXIMUM_DESCRIPTION_LENGTH}
  validates :display_name, presence: true, length: {maximum: 110}

  def parent_collections(user_context)
    super + [parent.parent.scenario_collection(user_context: user_context)]
  end

  class << self
    def iri_namespace
      NS::RIVM
    end
  end
end
