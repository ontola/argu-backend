# frozen_string_literal: true

class GroupSerializer < RecordSerializer
  include Parentable::Serializer
  attribute :display_name, predicate: NS::SCHEMA[:name], datatype: NS::XSD[:string]
  attribute :name_singular, predicate: NS::ARGU[:nameSingular]

  has_one :organization do
    object.parent
  end

  has_one :creator, predicate: NS::SCHEMA[:creator] do
    nil
  end
end
