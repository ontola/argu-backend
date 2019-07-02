# frozen_string_literal: true

module CacheableIri
  def root_relative_iri(opts = {})
    iri_path_from_cache(opts) || super
  end

  def iri_path_from_cache(opts = {})
    return if opts.present? || !persisted?

    RDF::URI(iri_cache || cache_iri_path!)
  end

  def cache_iri_path!
    @iri = nil
    return unless persisted?
    iri = root_relative_iri(cache: true)
    update_column(:iri_cache, iri.to_s) # rubocop:disable Rails/SkipsModelValidations
    iri
  end
end
