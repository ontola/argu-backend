# frozen_string_literal: true

class ArgumentPolicy < EdgePolicy
  def class_name
    'ProArgument'
  end

  permit_attributes %i[display_name description pro]
end
