# frozen_string_literal: true

class ShortnameInput
  include Formtastic::Inputs::Base
  include Formtastic::Inputs::Base::Stringish
  include Formtastic::Inputs::Base::Placeholder
  include ActionView::Helpers::TagHelper

  # rubocop:disable Rails/OutputSafety
  def to_html
    input_wrapping do
      label_html <<
        [
          content_tag(:span, "#{base_url}/"),
          builder.text_field(method, input_html_options)
        ].join("\n").html_safe
    end
  end
  # rubocop:enable Rails/OutputSafety

  private

  def base_url # rubocop:disable Metrics/AbcSize
    return Rails.application.config.origin if options[:root] == false || object.is_a?(Page)
    return object.root.iri if object.is_a?(Shortname)
    object.root.iri
  end
end
