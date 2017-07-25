# frozen_string_literal: true
class ReactCoverInput < ReactInput
  def to_html
    input_wrapping do
      label_html <<
        render_react_component(react_render_options, prerender: true)
    end
  end

  def render_react_component(props = {}, opts = {})
    photo = object.send(method)
    props[:cache] = photo&.content_cache
    props[:photoId] = photo&.id
    props[:imageUrl] = photo&.url
    props[:positionY] = photo&.content_attributes.try(:[], 'position_y') || 50
    props[:name] = "#{object.model_name.singular}[#{method}_attributes]"
    props[:type] = :cover_photo
    InputReactComponent.new.render_react_component('CoverUploader', props, opts)
  end
end
