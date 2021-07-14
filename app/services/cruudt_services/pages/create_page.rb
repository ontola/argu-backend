# frozen_string_literal: true

class CreatePage < CreateEdge
  def commit
    resource.errors.add(:iri_prefix, :blank) if resource.iri_prefix.blank?
    ActsAsTenant.with_tenant(resource) { super }
  end

  private

  def initialize_edge(_parent, attributes)
    Page.new(
      created_at: attributes.with_indifferent_access[:created_at],
      publisher: publisher,
      creator: creator,
      profile: Profile.new
    )
  end

  def object_attributes=(_obj); end
end
