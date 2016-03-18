class ReactSelectInput < ReactInput
  def to_html
    input_wrapping do
      label_html <<
          render_react_component(react_render_options, {prerender: true})
    end
  end

  def render_react_component(props = {}, opts = {})
    InputReactComponent.new.render_react_component('Select', props, opts)
  end
end
