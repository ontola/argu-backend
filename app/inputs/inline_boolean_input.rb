# frozen_string_literal: true

class InlineBooleanInput < Formtastic::Inputs::BooleanInput
  def to_html
    check_box_html
  end
end
