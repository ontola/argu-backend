# frozen_string_literal: true

class Incident < Edge
  include Edgeable::Content
  enhance Attachable
  enhance Scenariable

  parentable :risk
  validates :description, length: {maximum: 5000}
  validates :display_name, presence: true, length: {maximum: 110}

  class << self
    def iri_namespace
      NS::RIVM
    end
  end
end
