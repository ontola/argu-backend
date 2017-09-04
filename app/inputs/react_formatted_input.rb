# frozen_string_literal: true

class ReactFormattedInput < ReactInput
  def to_html
    input_wrapping do
      label_html <<
        render_react_component(react_render_options, prerender: true)
    end
  end

  def react_render_options
    Hash[
      input_options
        .merge(name: react_name)
        .map { |k, v| [k.to_s.camelize(:lower), v] }
    ]
  end

  def render_react_component(props = {}, opts = {})
    InputReactComponent.new.render_react_component('FormattedInput', props, opts)
  end
end
