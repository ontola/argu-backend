# frozen_string_literal: true

class ImageObject < MediaObject
  def iri_template_name
    :media_objects_iri
  end

  def invalidation_statements
    super.concat(MediaObjectUploader::IMAGE_VERSIONS.keys.map { |v| public_url_for_version(v) })
  end

  class << self
    def iri
      NS.schema.ImageObject
    end

    def content_type_white_list
      MediaObjectUploader::IMAGE_TYPES
    end
  end
end
