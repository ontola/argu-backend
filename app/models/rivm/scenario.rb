# frozen_string_literal: true

class Scenario < Edge
  include Edgeable::Content
  enhance Attachable

  parentable :incident
  validates :description, length: {maximum: 5000}
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
