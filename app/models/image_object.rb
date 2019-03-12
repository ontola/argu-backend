# frozen_string_literal: true

class ImageObject < MediaObject
  def iri_template_name
    :media_objects_iri
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
