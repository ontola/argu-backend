# frozen_string_literal: true
class InlineCheckBoxesInput < Formtastic::Inputs::CheckBoxesInput
  def legend_html
    if render_label?
      template.content_tag(
        :span,
        template.content_tag(:label, label_text),
        label_html_options.merge(class: 'label')
      )
    else
      ''
    end
  end
end
