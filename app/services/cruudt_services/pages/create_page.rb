# frozen_string_literal: true

class CreatePage < CreateEdge
  def initialize(parent, attributes: {}, options: {})
    attributes[:iri_prefix] ||= "#{Rails.application.config.host_name}/#{attributes[:url]}"
    super
  end

  def commit
    ActsAsTenant.with_tenant(resource) { super }
  end

  private

  def initialize_edge(_parent, options, attributes)
    Page.new(
      created_at: attributes.with_indifferent_access[:created_at],
      publisher: options[:publisher],
      creator: options[:creator],
      profile: Profile.new
    )
  end

  def object_attributes=(_obj); end
end
