# frozen_string_literal: true

class Risk < Edge
  include Edgeable::Content
  enhance Attachable
  enhance Commentable
  enhance Feedable
  enhance Statable
  enhance MeasureTypeable
  enhance PublicGrantable
  enhance Incidentable

  parentable :page, :measure_type
  validates :description, length: {maximum: MAXIMUM_DESCRIPTION_LENGTH}
  validates :display_name, presence: true, length: {maximum: 110}

  def default_public_grant
    :participator
  end

  class << self
    def iri_namespace
      NS::RIVM
    end
  end
end
