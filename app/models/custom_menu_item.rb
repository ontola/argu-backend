# frozen_string_literal: true

class CustomMenuItem < ApplicationRecord
  belongs_to :resource, polymorphic: true, primary_key: :uuid

  def iri_opts
    {
      id: id,
      menu_type: menu_type,
      parent_iri: split_iri_segments(resource.iri_path)
    }
  end

  def label
    label_translation ? I18n.t(super) : super
  end
end
