# frozen_string_literal: true

class ProjectForm < ContainerNodeForm
  fields [
    :display_name,
    {description: {datatype: NS::FHIR[:markdown]}},
    :default_cover_photo,
    :attachments,
    :custom_placement,
    :footer,
    :hidden
  ]

  property_group :footer,
                 iri: NS::ONTOLA[:footerGroup],
                 order: 99,
                 properties: [
                   creator: actor_selector
                 ]

  property_group :hidden,
                 order: 98,
                 iri: NS::ONTOLA[:hiddenGroup],
                 properties: %i[argu_publication]
end
