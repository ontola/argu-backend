# frozen_string_literal: true

class MeasureType < Edge
  include Edgeable::Content
  enhance Attachable
  enhance Commentable
  enhance Feedable
  enhance Statable
  enhance Measureable
  enhance Riskable
  enhance Categorizable
  enhance PublicGrantable
  enhance LinkedRails::Enhancements::Tableable

  parentable :page, :risk, :category
  with_columns default: [
    NS::SCHEMA[:name],
    NS::ARGU[:measuresCount]
  ]
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
