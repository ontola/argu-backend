# frozen_string_literal: true

module ActionableHelper
  def collection_create_url(col_name)
    RDF::URI(create_url(resource.send("#{col_name}_collection".to_sym)))
  end

  def create_url(resource)
    return resource.parent_view_iri if paged_resource?(resource)
    resource.iri
  end

  def paged_resource?(resource)
    resource.is_a?(Collection) && resource.pagination && resource.page.present?
  end
end
