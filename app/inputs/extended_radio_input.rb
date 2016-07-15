# frozen_string_literal: true
class ExtendedRadioInput < Formtastic::Inputs::RadioInput
  include ActionView::Helpers::TranslationHelper

  def to_html
    input_wrapping do
      choices_wrapping do
        legend_html <<
          choices_group_wrapping do
            collection.map do |choice|
              choice_wrapping(choice_wrapping_html_options(choice)) do
                choice_html(choice) <<
                  extended_hint_html(choice)
              end
            end.join("\n").html_safe
          end
      end
    end
  end

  def extended_hint_html(choice)
    template.content_tag(:span,
                         t("#{options[:t_preposition]}#{choice[1]}_desc"))
  end
end
