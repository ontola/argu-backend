# frozen_string_literal: true

class CustomActionSerializer < EdgeSerializer
  attribute :description, predicate: NS::SCHEMA.text
  attribute :raw_label, predicate: NS::ARGU[:menuLabel], datatype: NS::XSD[:string]
  attribute :label_translation, predicate: NS::ARGU[:labelTranslation]
  attribute :raw_description, predicate: NS::ARGU[:rawDescription], datatype: NS::XSD[:string]
  attribute :description_translation, predicate: NS::ARGU[:descriptionTranslation]
  attribute :raw_submit_label, predicate: NS::ARGU[:rawSubmitLabel], datatype: NS::XSD[:string]
  attribute :submit_label_translation, predicate: NS::ARGU[:submitLabelTranslation]
  attribute :href, predicate: NS::ARGU[:rawHref], datatype: NS::XSD[:string]
  attribute :action_status, predicate: NS::SCHEMA.actionStatus

  has_one :target, predicate: NS::SCHEMA.target

  def raw_label
    object.attribute_in_database(:label)
  end

  def raw_description
    object.attribute_in_database(:description)
  end

  def raw_submit_label
    object.attribute_in_database(:submit_label)
  end
end
