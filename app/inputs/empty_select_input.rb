class EmptySelectInput < Formtastic::Inputs::SelectInput
  def to_html
    builder.select(input_name, '', input_options.merge(required: false, include_blank: false), input_html_options)
  end
end
