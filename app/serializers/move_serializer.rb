# frozen_string_literal: true

class MoveSerializer < BaseSerializer
  attribute :new_parent_id, datatype: NS::XSD[:string], predicate: NS::ARGU[:moveTo]
end
