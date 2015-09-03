class ReactSelectInput < Formtastic::Inputs::SelectInput
  class SelectInputReactComponent
    include React::Rails::ViewHelper
    include ActionView::Helpers
    include ActionView::Context

    def render_react_component(props = {}, opts = {})
      react_component('Select', props, opts)
    end
  end

  def to_html
    input_wrapping do
      label_html <<
          render_react_component(react_render_options, {prerender: false})
    end
  end

  def react_render_options
    {
        name: react_name,
        options: react_options,
        value: react_value
    }
  end

  def react_name
    input_html_options[:name]
  end

  def react_options
    collection.map { |k| {label: k[0], value: k[1]} }
  end

  def react_value
    @object.send(@method)
  end

  def render_react_component(props = {}, opts = {})
    SelectInputReactComponent.new.render_react_component(props, opts)
  end
end
