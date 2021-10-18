# frozen_string_literal: true

class BannerManagementsController < EdgeableController
  has_collection_create_action(
    label: -> { I18n.t('banners.type_new') },
    target_url: -> { Banner.collection_iri }
  )
end
