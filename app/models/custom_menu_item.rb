# frozen_string_literal: true

class CustomMenuItem < ApplicationRecord # rubocop:disable Metrics/ClassLength
  enhance LinkedRails::Enhancements::Creatable
  enhance LinkedRails::Enhancements::Updatable
  enhance LinkedRails::Enhancements::Destroyable
  enhance Orderable
  include Cacheable
  include TranslatableProperties

  with_columns default: [
    NS.argu[:order],
    NS.schema.name,
    NS.ontola[:href],
    NS.ontola[:updateAction],
    NS.ontola[:destroyAction]
  ]
  collection_options(
    association_scope: :navigations,
    display: :table
  )
  belongs_to :resource, polymorphic: true, primary_key: :uuid
  belongs_to :edge, primary_key: :uuid, optional: true
  belongs_to :root, primary_key: :uuid, class_name: 'Edge'
  belongs_to :parent_menu, class_name: 'CustomMenuItem', inverse_of: :custom_menu_items
  has_many :custom_menu_items, -> { order(:position) }, foreign_key: :parent_menu_id, inverse_of: :parent_menu
  acts_as_tenant :root, class_name: 'Edge', primary_key: :uuid
  has_one_attached :custom_image do |attachable|
    attachable.variant(:png, format: :png, resize_to_limit: [218, 64])
    attachable.variant(:svg, format: :svg, sanitize_svg: true)
  end
  delegate :content_type, to: :custom_image, prefix: true

  enum target_type: {edge: 0, url: 1}

  before_create :set_root

  attr_writer :parent

  alias edgeable_record resource

  # Make sure the feed menu item remains last
  def add_to_list_bottom
    super

    return true unless new_record? && bottom_item&.href&.to_s&.ends_with?('/feed')

    bottom_item.increment_position
    self.position -= 1
  end

  def custom_image_iri
    return unless custom_image&.attached?

    return RDF::URI(custom_image.variant(:svg).processed.url) if custom_image.content_type.include?('svg')

    RDF::URI(custom_image.variant(:png).processed.url)
  end

  def custom_image=(val)
    if val.blank?
      super(nil)
    elsif !(val.is_a?(String) && val.include?('http'))
      super
    end
  end

  def custom_image_content_type=(val); end

  def description; end

  def href
    edge&.iri || RDF::URI(super)
  end

  def image
    custom_image_iri || icon.presence
  end

  def label
    return edge.display_name if attribute_in_database(:label).blank? && edge.present?

    translate_property(super)
  end

  def menu_list(_user_context)
    @menu_list ||= Menus::List.new(resource: self, menus: menu_list.custom_menu_items(menu_type, self))
  end

  def menus_present?
    @menus_present ||= custom_menu_items.any?
  end

  def menu_sequence
    return unless menus_present?

    @menu_sequence ||=
      LinkedRails::Sequence.new(
        -> { custom_menu_items },
        id: menu_sequence_iri,
        scope: false
      )
  end

  def menu_sequence_iri
    return @menu_sequence_iri if @menu_sequence_iri

    sequence_iri = iri.dup
    sequence_iri.path ||= ''
    sequence_iri.path += '/menu_items'
    @menu_sequence_iri = sequence_iri
  end

  def parent
    @parent ||= parent_menu || resource&.menu(menu_type&.to_sym)
  end

  def parent_collections(user_context)
    [resource.custom_menu_item_collection(user_context: user_context)]
  end

  def added_delta
    super + [
      [parent.iri, NS.sp.Variable, NS.sp.Variable, NS.ontola[:invalidate]]
    ]
  end

  def raw_label=(value)
    self.label = value
  end

  def raw_href=(value)
    self.href = value
  end

  def target_type
    edge.present? ? :edge : :url
  end

  private

  def scope_condition
    {
      resource: resource,
      menu_type: menu_type
    }
  end

  def set_root
    self.root_id ||= resource.root_id
  end

  class << self
    def attributes_for_new(opts)
      {
        menu_type: :navigations,
        resource: opts[:parent] || ActsAsTenant.current_tenant
      }
    end

    def info
      where(menu_type: :info)
    end

    def iri
      NS.ontola[:MenuItem]
    end

    def navigations
      where(menu_type: :navigations)
    end

    def valid_parent?(_klass)
      true
    end
  end
end
