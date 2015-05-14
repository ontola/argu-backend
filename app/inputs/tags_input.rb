class TagsInput < Formtastic::Inputs::StringInput

  def to_html
    input_wrapping do
      label_html <<
          builder.text_field(method, input_html_options.merge({class: 'tag-list form-item'}))
    end
  end
end