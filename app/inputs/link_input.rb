# frozen_string_literal: true

class LinkInput < Formtastic::Inputs::StringInput
  include ActionView::Helpers::UrlHelper

  def to_html
    input_wrapping do
      label_html <<
        link_to(localized_string(method, method, :label), input_options[:url].to_s, input_html_options)
    end
  end
end
