# frozen_string_literal: true

class BannerManagementActionList < EdgeActionList
  has_collection_create_action(
    label: -> { I18n.t('banners.type_new') },
    url: -> { Banner.root_collection.iri }
  )
end
