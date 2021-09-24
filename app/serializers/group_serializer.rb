# frozen_string_literal: true

class GroupSerializer < RecordSerializer
  include Parentable::Serializer
  attribute :display_name, predicate: NS.schema.name, datatype: NS.xsd.string
  attribute :name_singular, predicate: NS.argu[:nameSingular]
  attribute :require_2fa, predicate: NS.argu[:require2fa]

  with_collection :group_membership, predicate: NS.org[:hasMember]

  has_one :organization do |object|
    object.parent
  end

  has_one :creator, predicate: NS.schema.creator do
    nil
  end
end
