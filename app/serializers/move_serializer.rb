# frozen_string_literal: true

class MoveSerializer < BaseSerializer
  attribute :new_parent_id, datatype: NS.xsd.string, predicate: NS.argu[:moveTo]
end
