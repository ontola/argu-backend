class LinkInput < Formtastic::Inputs::StringInput
  include ActionView::Helpers::UrlHelper

  def to_html
    input_wrapping do
      label_html <<
          link_to(input_name, input_options[:url].to_s, input_html_options)
    end
  end
end