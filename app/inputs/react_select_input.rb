class ReactSelectInput < ReactInput
  def to_html
    input_wrapping do
      label_html <<
        render_react_component(react_render_options)
    end
  end

  def render_react_component(props = {}, opts = {})
    InputReactComponent
      .new(request, controller)
      .render_react_component('Select', props, opts)
  end
end
