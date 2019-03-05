# frozen_string_literal: true

class MotionForm < RailsLD::Form
  fields [
    :display_name,
    :description,
    :default_cover_photo,
    {mark_as_important: {description: ->(resource) { mark_as_important_label(resource) }}},
    :attachments,
    :custom_placement,
    :advanced,
    :footer
  ]

  property_group :advanced,
                 label: I18n.t('forms.advanced'),
                 properties: %i[
                   argu_publication
                   pinned
                   expires_at
                   invert_arguments
                 ]

  property_group :footer,
                 iri: NS::ONTOLA[:footerGroup],
                 properties: [
                   creator: actor_selector
                 ]

  class << self
    private

    def mark_as_important_label(resource)
      I18n.t(
        'publications.follow_type.helper',
        news_audience: resource.parent.potential_audience(:news),
        reactions_audience: resource.parent.potential_audience(:reactions)
      )
    end
  end
end
