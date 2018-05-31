# frozen_string_literal: true

class CustomMenuItem < ApplicationRecord
  belongs_to :resource, polymorphic: true, primary_key: :uuid

  def iri_opts
    {
      id: id,
      menu_type: menu_type,
      parent_iri: resource.iri(only_path: true)
    }
  end

  def label
    label_translation ? I18n.t(super) : super
  end
end
