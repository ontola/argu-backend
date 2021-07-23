# frozen_string_literal: true

class CustomMenuItem < ApplicationRecord # rubocop:disable Metrics/ClassLength
  enhance LinkedRails::Enhancements::Creatable
  enhance LinkedRails::Enhancements::Updatable
  enhance LinkedRails::Enhancements::Destroyable
  enhance Orderable
  include TranslatableProperties

  with_columns default: [
    NS.schema.name,
    NS.ontola[:href],
    NS.argu[:order],
    NS.ontola[:updateAction],
    NS.ontola[:destroyAction]
  ]
  belongs_to :resource, polymorphic: true, primary_key: :uuid
  belongs_to :edge, primary_key: :uuid, optional: true
  belongs_to :root, primary_key: :uuid, class_name: 'Edge'
  belongs_to :parent_menu, class_name: 'CustomMenuItem', inverse_of: :custom_menu_items
  has_many :custom_menu_items, -> { order(:order) }, foreign_key: :parent_menu_id, inverse_of: :parent_menu
  acts_as_tenant :root, class_name: 'Edge', primary_key: :uuid

  before_create :set_root

  attr_writer :parent

  alias edgeable_record resource

  def href
    super.present? ? RDF::URI(super) : edge&.iri
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
  alias removed_delta added_delta

  def raw_label=(value)
    self.label = value
  end

  def raw_href=(value)
    self.href = value
  end

  def raw_image=(value)
    self.image = value.presence
  end

  private

  def order_scope
    CustomMenuItem.where(resource: resource, menu_type: menu_type).where('custom_menu_items.order < ?', 100)
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

    def default_collection_display
      :table
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

    def root_collection_opts
      super.merge(association_scope: :navigations)
    end

    def valid_parent?(_klass)
      true
    end
  end
end
