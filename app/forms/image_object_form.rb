# frozen_string_literal: true

class ImageObjectForm < ApplicationForm
  field :content

  hidden do
    field :content_type, sh_in: -> { MediaObjectUploader::IMAGE_TYPES }
    field :position_y
  end
end
