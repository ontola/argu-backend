# frozen_string_literal: true

class CreatePage < CreateEdge
  def commit
    resource.errors.add(:iri_prefix, :blank) if resource.iri_prefix.blank?
    ActsAsTenant.with_tenant(resource) { super }
  end

  private

  def initialize_edge(_parent, attributes)
    attrs = {
      publisher: publisher,
      creator: creator,
      profile: Profile.new
    }.merge(
      attributes.with_indifferent_access.slice(:created_at, :uuid, :root_id)
    )
    Page.new(attrs)
  end

  def object_attributes=(_obj); end
end
