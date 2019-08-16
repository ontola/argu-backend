# frozen_string_literal: true

class Risk < Edge
  include Edgeable::Content
  enhance Attachable
  enhance Commentable
  enhance Feedable
  enhance Statable
  enhance InterventionTypeable
  enhance PublicGrantable

  parentable :page, :intervention_type
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
