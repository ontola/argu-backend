# frozen_string_literal: true

class InlineSelectInput < Formtastic::Inputs::SelectInput
  def to_html
    select_html
  end
end
