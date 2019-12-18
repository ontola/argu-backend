# frozen_string_literal: true

class CustomMenuItem < ApplicationRecord
  enhance LinkedRails::Enhancements::Actionable
  enhance LinkedRails::Enhancements::Creatable
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
  acts_as_tenant :root, class_name: 'Edge', primary_key: :uuid

  before_create :set_order
  before_create :set_root

  attr_writer :parent
  alias edgeable_record resource

  def href
    super || edge&.iri
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

  def parent
    @parent ||= resource&.menu(menu_type&.to_sym)
  end

  def parent_collections(user_context)
    [resource.custom_menu_item_collection(user_context: user_context)]
  end

  def resource_added_delta
    [
      [parent.iri, NS::SP[:Variable], NS::SP[:Variable], NS::ONTOLA[:invalidate]]
    ]
  end
  alias resource_removed_delta resource_added_delta

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
    def default_collection_display
      :table
    end

    def info
      where(menu_type: :info)
    end

    def navigations
      where(menu_type: :navigations)
    end

    def valid_parent?(_klass)
      true
    end
  end
end
