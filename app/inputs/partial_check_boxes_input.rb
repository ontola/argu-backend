# frozen_string_literal: true

class PartialCheckBoxesInput < Formtastic::Inputs::CheckBoxesInput
  def to_html # rubocop:disable Metrics/AbcSize
    input_wrapping do
      choices_wrapping do
        hidden_field_for_all <<
          choices_group_wrapping do
            @options[:collection].map do |choice|
              choice_wrapping(choice_wrapping_html_options(choice)) do
                template.content_tag :label do
                  template.concat template.check_box_tag(
                    input_name,
                    choice.id,
                    choice.is_checked,
                    extra_html_options(choice).merge(id: choice_input_dom_id(choice), required: false)
                  )
                  template.concat template.render partial: (options[:partial].presence || 'container_nodes/forum'),
                                                  object: choice,
                                                  locals: {forum: choice}
                end
              end
            end.join("\n").html_safe
          end
      end
    end
  end
end
