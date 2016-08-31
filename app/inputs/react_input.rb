class ReactInput < Formtastic::Inputs::SelectInput
  attr_reader :request, :controller

  def initialize(*opts)
    context = opts.find { |i| defined?(i.controller) }
    @request = context.try(:request) || opts[0]
    @controller = context.try(:controller) || opts[1]
    super(*opts)
  end

  class InputReactComponent
    include ReactOnRailsHelper
    include ActionView::Helpers
    include ActionView::Context

    attr_reader :request, :controller

    def initialize(*opts)
      context = opts.find { |i| defined?(i.controller) }
      @request = context.try(:request) || opts[0]
      @controller = context.try(:controller) || opts[1]
    end

    def render_react_component(component, props = {}, opts = {})
      react_component(component, props: props, **opts)
    end
  end

  def to_html
    input_wrapping do
      label_html <<
        render_react_component(@options[:component], react_render_options)
    end
  end

  def react_render_options
    input_options.merge(
      name: react_name,
      options: react_options,
      value: react_value)
  end

  def react_name
    input_html_options[:name]
  end

  def react_options
    collection.map { |k| {label: k[0], value: k[1]} }
  end

  def react_value
    @object.send(@method) if @object.present?
  end

  def render_react_component(component, props = {}, opts = {})
    InputReactComponent
      .new(request, controller)
      .render_react_component(component, props, opts)
  end
end
