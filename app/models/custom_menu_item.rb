# frozen_string_literal: true

class CustomMenuItem < ApplicationRecord
  belongs_to :resource, polymorphic: true, primary_key: :uuid
  belongs_to :edge, primary_key: :uuid, optional: true

  before_create :set_order

  def href
    super || edge&.iri
  end

  def iri_opts
    {
      id: id,
      menu_type: menu_type,
      parent_iri: split_iri_segments(resource.iri_path)
    }
  end

  def label
    return edge.display_name if edge.present?

    label_translation ? I18n.t(super) : super
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

  class << self
    def info
      where(menu_type: :info)
    end

    def navigations
      where(menu_type: :navigations)
    end
  end
end
