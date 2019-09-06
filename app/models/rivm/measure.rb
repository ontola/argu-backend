# frozen_string_literal: true

class Measure < Edge
  include Edgeable::Content
  enhance Attachable
  enhance Commentable
  enhance Feedable
  enhance Statable

  parentable :measure_type
  validates :description, length: {maximum: 5000}
  validates :display_name, presence: true, length: {maximum: 110}

  class << self
    def iri_namespace
      NS::RIVM
    end
  end
end
