# frozen_string_literal: true

class CollectionView < LinkedRails::Collection::View
  include UriTemplateHelper

  def canonical_iri(opts = {})
    RDF::URI(path_with_hostname(canonical_iri_path(opts)))
  end

  def canonical_iri_path(opts = {})
    collection.unfiltered.canonical_iri_template.expand(iri_opts.merge(opts))
  end

  def iri(opts = {})
    super(opts.except(:parent_iri))
  end

  def members
    m = super
    if association_class <= Edge && association_class != Page
      m.each { |member| user_context.grant_tree.cache_node(member) }
    end
    m
  end
end
