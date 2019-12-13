# frozen_string_literal: true

class CustomAction < Edge
  enhance LinkedRails::Enhancements::Creatable
  enhance LinkedRails::Enhancements::Updatable
  enhance LinkedRails::Enhancements::Destroyable
  enhance LinkedRails::Enhancements::Menuable

  property :label, :string, NS::SCHEMA.name
  property :label_translation, :boolean, NS::ARGU[:labelTranslation], default: false
  property :description, :text, NS::SCHEMA.text
  property :description_translation, :boolean, NS::ARGU[:descriptionTranslation], default: false
  property :submit_label, :string, NS::ARGU[:submitLabel]
  property :submit_label_translation, :boolean, NS::ARGU[:submitLabelTranslation], default: false
  property :href, :text, NS::SCHEMA.url

  parentable :container_node

  def action_status
    NS::SCHEMA.potentialAction
  end

  def description
    description_translation ? LinkedRails.translations(-> { I18n.t(super) }) : super
  end

  def display_name
    label_translation ? LinkedRails.translations(-> { I18n.t(label) }) : label
  end

  def form; end

  def http_method
    'GET'
  end

  def image; end

  def raw_label=(value)
    self.label = value
  end

  def raw_description=(value)
    self.description = value
  end

  def raw_submit_label=(value)
    self.submit_label = value
  end

  def submit_label
    submit_label_translation ? LinkedRails.translations(-> { I18n.t(super) }) : super
  end

  def target
    @target ||= LinkedRails.entry_point_class.new(parent: self, url: href)
  end

  class << self
    def iri
      NS::SCHEMA.Action
    end
  end
end
