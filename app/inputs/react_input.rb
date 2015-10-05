class ReactInput < Formtastic::Inputs::SelectInput
  class InputReactComponent
    include React::Rails::ViewHelper
    include ActionView::Helpers
    include ActionView::Context

    def initialize
      new_helper = React::Rails::ViewHelper.helper_implementation_class.new
      new_helper.setup(self)
      @__react_component_helper = new_helper    end

    def render_react_component(component, props = {}, opts = {})
      react_component(component, props, opts)
    end
  end

  def to_html
    input_wrapping do
      label_html <<
          render_react_component(@options[:component], react_render_options, {prerender: false})
    end
  end

  def react_render_options
    input_options.merge({
        name: react_name,
        options: react_options,
        value: react_value
    })
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

  def render_react_component(component, props = {}, opts = {})
    InputReactComponent.new.render_react_component(component, props, opts)
  end
end
