# frozen_string_literal: true

class CustomActionSerializer < EdgeSerializer
  attribute :raw_label, predicate: NS.argu[:menuLabel], datatype: NS.xsd.string do |object|
    object.attribute_in_database(:label)
  end
  attribute :raw_description, predicate: NS.argu[:rawDescription], datatype: NS.xsd.string do |object|
    object.attribute_in_database(:description)
  end
  attribute :raw_submit_label, predicate: NS.argu[:rawSubmitLabel], datatype: NS.xsd.string do |object|
    object.attribute_in_database(:submit_label)
  end
  attribute :href, predicate: NS.argu[:rawHref], datatype: NS.xsd.string
  attribute :url, predicate: NS.schema.url {}
  attribute :action_status, predicate: NS.schema.actionStatus

  has_one :target, predicate: NS.schema.target, serializer: EntryPointSerializer
end
