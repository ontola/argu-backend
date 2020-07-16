# frozen_string_literal: true

class ImageObject < MediaObject
  def iri_template_name
    :media_objects_iri
  end

  def invalidate_cache(cache)
    ActsAsTenant.with_tenant(try(:root) || ActsAsTenant.current_tenant) do
      delta = [
        [iri, LinkedRails::Vocab::SP[:Variable], LinkedRails::Vocab::SP[:Variable], delta_iri(:invalidate)]
      ].concat(MediaObjectUploader::IMAGE_VERSIONS.keys.map { |v| url_for_version(v) })
      cache.write(delta)
    end
  end

  class << self
    def iri
      NS::SCHEMA[:ImageObject]
    end

    def content_type_white_list
      MediaObjectUploader::IMAGE_TYPES
    end
  end
end
