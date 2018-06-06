# frozen_string_literal: true

class GroupSerializer < RecordSerializer
  include Parentable::Serializer

  has_one :organization do
    object.parent
  end

  has_one :creator, predicate: NS::SCHEMA[:creator] do
    nil
  end
end
