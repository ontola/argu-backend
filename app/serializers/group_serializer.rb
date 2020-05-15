# frozen_string_literal: true

class GroupSerializer < RecordSerializer
  include Parentable::Serializer
  attribute :display_name, predicate: NS::SCHEMA[:name], datatype: NS::XSD[:string]
  attribute :name_singular, predicate: NS::ARGU[:nameSingular]

  with_collection :group_membership, predicate: NS::ORG[:hasMember]

  has_one :organization, &:parent

  has_one :creator, predicate: NS::SCHEMA[:creator] do
    nil
  end
end
