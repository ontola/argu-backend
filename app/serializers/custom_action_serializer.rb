# frozen_string_literal: true

class CustomActionSerializer < EdgeSerializer
  attribute :description, predicate: NS::SCHEMA.text
  attribute :raw_label, predicate: NS::ARGU[:menuLabel], datatype: NS::XSD[:string] do |object|
    object.attribute_in_database(:label)
  end
  attribute :label_translation, predicate: NS::ARGU[:labelTranslation]
  attribute :raw_description, predicate: NS::ARGU[:rawDescription], datatype: NS::XSD[:string] do |object|
    object.attribute_in_database(:description)
  end
  attribute :description_translation, predicate: NS::ARGU[:descriptionTranslation]
  attribute :raw_submit_label, predicate: NS::ARGU[:rawSubmitLabel], datatype: NS::XSD[:string] do |object|
    object.attribute_in_database(:submit_label)
  end
  attribute :submit_label_translation, predicate: NS::ARGU[:submitLabelTranslation]
  attribute :href, predicate: NS::ARGU[:rawHref], datatype: NS::XSD[:string]
  attribute :action_status, predicate: NS::SCHEMA.actionStatus

  has_one :target, predicate: NS::SCHEMA.target, serializer: EntryPointSerializer
end
