# frozen_string_literal: true

class ImageObjectForm < ApplicationForm
  field :content, min_count: 1

  hidden do
    field :content_type, sh_in: -> { MediaObjectUploader::IMAGE_TYPES }
    field :position_y
    field :filename
  end
end
