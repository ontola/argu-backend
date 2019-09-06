# frozen_string_literal: true

class MeasureType < Edge
  include Edgeable::Content
  enhance Attachable
  enhance Commentable
  enhance Feedable
  enhance Statable
  enhance Measureable
  enhance Riskable
  enhance PublicGrantable
  enhance LinkedRails::Enhancements::Tableable

  parentable :page, :risk
  with_columns default: [
    NS::SCHEMA[:name],
    NS::SCHEMA[:dateCreated]
  ]
  validates :description, length: {maximum: 5000}
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
