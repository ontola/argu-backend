# frozen_string_literal: true

class ManifestSerializer < ActiveModel::Serializer
  attributes(
    :background_color,
    :description,
    :dir,
    :display,
    :icons,
    :lang,
    :name,
    :ontola,
    :serviceworker,
    :short_name,
    :start_url,
    :theme_color
  )
  attribute :manifest_scope, key: :scope
end
