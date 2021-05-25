# frozen_string_literal: true

class CustomMenuItem < ApplicationRecord # rubocop:disable Metrics/ClassLength
  enhance LinkedRails::Enhancements::Actionable
  enhance LinkedRails::Enhancements::Creatable
  enhance LinkedRails::Enhancements::Indexable
  enhance LinkedRails::Enhancements::Updatable
  enhance LinkedRails::Enhancements::Destroyable
  enhance LinkedRails::Enhancements::Tableable

  with_columns default: [
    NS::SCHEMA[:name],
    NS::ONTOLA[:href],
    NS::ARGU[:order],
    NS::ONTOLA[:updateAction],
    NS::ONTOLA[:destroyAction]
  ]
  self.default_sortings = [{key: NS::ARGU[:order], direction: :asc}]

  belongs_to :resource, polymorphic: true, primary_key: :uuid
  belongs_to :edge, primary_key: :uuid, optional: true
  belongs_to :root, primary_key: :uuid, class_name: 'Edge'
  belongs_to :parent_menu, class_name: 'CustomMenuItem', inverse_of: :custom_menu_items
  has_many :custom_menu_items, -> { order(:order) }, foreign_key: :parent_menu_id, inverse_of: :parent_menu
  acts_as_tenant :root, class_name: 'Edge', primary_key: :uuid

  before_create :set_order
  before_create :set_root

  attr_writer :parent

  alias edgeable_record resource

  def href
    super.present? ? RDF::URI(super) : edge&.iri
  end

  def iri_opts
    {
      id: id,
      menu_type: menu_type,
      parent_iri: split_iri_segments(resource&.iri_path)
    }
  end
  alias canonical_iri_opts iri_opts

  def label
    return edge.display_name if attribute_in_database(:label).blank? && edge.present?

    label_translation ? I18n.t(super) : super
  end

  def menus_present?
    @menus_present ||= custom_menu_items.any?
  end

  def menu_sequence
    return unless menus_present?

    @menu_sequence ||=
      LinkedRails::Sequence.new(
        -> { custom_menu_items },
        id: menu_sequence_iri
      )
  end

  def menu_sequence_iri
    return @menu_sequence_iri if @menu_sequence_iri

    sequence_iri = iri.dup
    sequence_iri.path ||= ''
    sequence_iri.path += '/menus'
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
      [parent.iri, NS::SP[:Variable], NS::SP[:Variable], NS::ONTOLA[:invalidate]]
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

  def set_order
    self.order ||= (
      CustomMenuItem
        .where(resource: resource, menu_type: menu_type)
        .where('custom_menu_items.order < ?', 100)
        .maximum(:order) || 0
    ) + 1
  end

  def set_root
    self.root_id ||= resource.root_id
  end

  class << self
    def attributes_for_new(opts)
      {
        menu_type: :navigations,
        resource: opts[:parent]
      }
    end

    def default_collection_display
      :table
    end

    def info
      where(menu_type: :info)
    end

    def iri
      NS::ONTOLA[:MenuItem]
    end

    def navigations
      where(menu_type: :navigations)
    end

    def valid_parent?(_klass)
      true
    end
  end
end
