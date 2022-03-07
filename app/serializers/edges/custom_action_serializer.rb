# frozen_string_literal: true

class CustomActionSerializer < EdgeSerializer
  attribute :description, predicate: NS.schema.text
  attribute :raw_label, predicate: NS.argu[:menuLabel], datatype: NS.xsd.string
  attribute :raw_description, predicate: NS.argu[:rawDescription], datatype: NS.xsd.string
  attribute :raw_submit_label, predicate: NS.argu[:rawSubmitLabel], datatype: NS.xsd.string
  attribute :href, predicate: NS.argu[:rawHref], datatype: NS.xsd.string
  attribute :action_status, predicate: NS.schema.actionStatus

  has_one :target, predicate: NS.schema.target, serializer: EntryPointSerializer
end
