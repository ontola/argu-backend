class ToggleRadioInput < Formtastic::Inputs::RadioInput
  include ActionView::Helpers::TranslationHelper

  def choice_html(choice)
    template.content_tag(
      :label,
      builder.radio_button(input_name,
                           choice_value(choice),
                           input_html_options.merge(choice_html_options(choice)).merge(required: false)) <<
        choice_label(choice),
      label_html_options.merge(for: choice_input_dom_id(choice),
                               class: choice_html_options(choice)[:class]))
  end
end
