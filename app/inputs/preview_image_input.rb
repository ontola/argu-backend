class PreviewImageInput < Formtastic::Inputs::TextInput
  include ActionView::Helpers::AssetTagHelper

  def to_html
    input_wrapping do
      label_html <<
        image_tag(object.send(method).url, options[:html_options])
    end
  end
end
