# frozen_string_literal: true

class InterventionType < Edge
  include Edgeable::Content
  enhance Attachable
  enhance Commentable
  enhance Feedable
  enhance Statable
  enhance Interventionable
  enhance RootGrantable
  enhance LinkedRails::Enhancements::Tableable

  parentable :page
  with_columns default: [
    NS::SCHEMA[:name],
    NS::ARGU[:interventionsCount]
  ]

  property :one_off_costs_score, :integer, NS::RIVM[:oneOffCostsScore], default: 0
  property :recurring_costs_score, :integer, NS::RIVM[:recurringCostsScore], default: 0
  property :security_improved_score, :integer, NS::RIVM[:securityImprovedScore], default: 0

  self.default_sortings = [{key: NS::ARGU[:interventionsCount], direction: :desc}]
  validates :description, length: {maximum: MAXIMUM_DESCRIPTION_LENGTH}
  validates :display_name, presence: true, length: {maximum: 110}

  def sync_scores
    update(
      one_off_costs_score: average_score(NS::RIVM[:oneOffCosts]),
      recurring_costs_score: average_score(NS::RIVM[:recurringCosts]),
      security_improved_score: average_score(NS::RIVM[:securityImproved])
    )
  end

  private

  def average_score(predicate)
    descendants.active.joins(:properties).where(properties: {predicate: predicate.to_s}).average(:integer).to_f * 100
  end

  class << self
    def default_public_grant
      :participator
    end

    def iri_namespace
      NS::RIVM
    end

    def default_collection_display
      :table
    end

    def default_per_page
      30
    end

    def sort_options(collection)
      return super if collection.type == :infinite

      [
        NS::SCHEMA[:name],
        NS::SCHEMA[:dateCreated],
        NS::RIVM[:oneOffCostsScore],
        NS::RIVM[:recurringCostsScore],
        NS::RIVM[:securityImprovedScore]
      ]
    end

    def unknown
      find_or_create_by(parent: ActsAsTenant.current_tenant, display_name: 'Weet ik niet')
    end
  end
end
