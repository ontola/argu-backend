# frozen_string_literal: true

class CustomAction < Edge
  enhance LinkedRails::Enhancements::Creatable
  enhance LinkedRails::Enhancements::Updatable
  enhance LinkedRails::Enhancements::Destroyable
  enhance LinkedRails::Enhancements::Menuable
  include TranslatableProperties

  property :label, :string, NS.schema.name
  property :description, :text, NS.schema.text
  property :submit_label, :string, NS.argu[:submitLabel]
  property :href, :text, NS.schema.url

  parentable :container_node

  def action_status
    NS.schema.PotentialActionStatus
  end

  def description
    translate_property(super)
  end

  def display_name
    translate_property(label)
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

  def searchable_should_index?
    false
  end

  def submit_label
    translate_property(super)
  end

  def tag
    :create
  end

  def target
    @target ||= LinkedRails.entry_point_class.new(parent: self, url: href)
  end

  def target_id
    target.iri
  end

  def translation_key
    :default
  end

  class << self
    def preview_includes
      %i[target]
    end
  end
end
