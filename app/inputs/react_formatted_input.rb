# frozen_string_literal: true

class ReactFormattedInput < ReactInput
  def react_component
    'FormattedInput'
  end

  def react_render_props
    Hash[
      input_options
        .merge(name: react_name)
        .map { |k, v| [k.to_s.camelize(:lower), v] }
    ]
  end
end
