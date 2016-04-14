# frozen_string_literal: true
class ReactMarkdownInput < ReactInput
  include ActionView::Helpers::FormTagHelper

  def to_html
    input_wrapping do
      html = []
      html << template.text_area_tag(react_name,
                                     react_value,
                                     placeholder: options[:placeholder],
                                     rows: options[:rows] || 4,
                                     class: options[:class])
      html << render_react_component(react_render_options, prerender: false) unless Rails.env.test?
      safe_join(html)
    end
  end

  def input_options
    super.except(:include_blank)
  end

  def react_render_options
    input_options.merge(
      name: react_name,
      value: react_value || ''
    )
  end

  def render_react_component(props = {}, opts = {})
    InputReactComponent.new.render_react_component('TextEditor', props, opts)
  end
end
