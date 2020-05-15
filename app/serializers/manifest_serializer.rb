# frozen_string_literal: true

class ManifestSerializer < BaseSerializer
  attributes(
    :background_color,
    :dir,
    :display,
    :icons,
    :lang,
    :name,
    :ontola,
    :serviceworker,
    :short_name,
    :start_url,
    :scope,
    :theme_color
  )
end
