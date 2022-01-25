# frozen_string_literal: true

class CustomAction < Edge
  enhance LinkedRails::Enhancements::Creatable
  enhance LinkedRails::Enhancements::Updatable
  enhance LinkedRails::Enhancements::Destroyable
  include TranslatableProperties

  property :raw_label, :string, NS.schema.name
  property :raw_description, :text, NS.schema.text
  property :raw_submit_label, :string, NS.argu[:submitLabel]
  property :href, :text, NS.schema.url

  parentable :container_node

  def action_status
    NS.schema.PotentialActionStatus
  end

  def description
    translate_property(raw_description)
  end

  def display_name
    translate_property(raw_label)
  end

  def form; end

  def http_method
    'GET'
  end

  def image; end

  def searchable_should_index?
    false
  end

  def submit_label
    translate_property(raw_submit_label)
  end

  def tag
    :create
  end

  def target
    @target ||= LinkedRails.entry_point_class.new(parent: self, target_url: href)
  end

  def target_id
    target.iri
  end

  def translation_key
    :default
  end
end
