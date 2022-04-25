# frozen_string_literal: true

class PollPolicy < EdgePolicy
  permit_attributes %i[display_name description]
  permit_nested_attributes %i[options_vocab]
end
