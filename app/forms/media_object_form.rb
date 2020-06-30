# frozen_string_literal: true

class MediaObjectForm < ApplicationForm
  field :content
  field :remote_content_url

  hidden do
    field :content_type, sh_in: -> { MediaObject.content_type_white_list }
  end
end
