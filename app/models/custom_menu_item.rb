# frozen_string_literal: true

class CustomMenuItem < ApplicationRecord
  belongs_to :resource, polymorphic: true

  def iri_opts
    {
      id: id,
      menu_type: menu_type,
      parent_iri: parent_iri(true)
    }
  end

  def label
    label_translation ? I18n.t(super) : super
  end

  private

  def parent_iri(only_path = false)
    expand_uri_template(
      "#{resource_type.underscore.pluralize}_iri",
      id: resource_id,
      path_only: only_path
    )
  end
end
