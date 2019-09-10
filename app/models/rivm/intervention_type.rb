# frozen_string_literal: true

class InterventionType < Edge
  include Edgeable::Content
  enhance Attachable
  enhance Commentable
  enhance Feedable
  enhance Statable
  enhance Interventionable
  enhance PublicGrantable
  enhance LinkedRails::Enhancements::Tableable

  parentable :page
  with_columns default: [
    NS::SCHEMA[:name],
    NS::ARGU[:interventionsCount],
    NS::SCHEMA[:datePublished]
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

    def unknown
      find_or_create_by(parent: ActsAsTenant.current_tenant, display_name: 'Weet ik niet')
    end
  end
end
