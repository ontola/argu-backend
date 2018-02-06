# frozen_string_literal: true

class ReactCoverInput < ReactInput
  def react_component
    'CoverUploader'
  end

  def react_render_props
    photo = object.send(method)
    {
      cache: photo&.content_cache,
      photoId: photo&.id,
      imageUrl: photo&.url,
      positionY: photo&.content_attributes.try(:[], 'position_y') || 50,
      name: "#{object.model_name.singular}[#{method}_attributes]",
      type: :cover_photo
    }
  end
end
