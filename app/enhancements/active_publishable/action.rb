# frozen_string_literal: true

module ActivePublishable
  module Action
    extend ActiveSupport::Concern

    included do
      has_resource_action(
        :publish,
        type: [NS.schema.Action, NS.argu[:PublishAction]],
        policy: :publish?,
        http_method: :put,
        image: 'fa-send',
        url: lambda {
          RDF::URI(
            [
              resource.iri,
              {
                resource.model_name.param_key => {
                  argu_publication_attributes: {id: resource.argu_publication.id, published_at: Time.current}
                }
              }.to_param
            ].join('?')
          )
        },
        condition: -> { !resource.argu_publication&.publish_time_lapsed? }
      )
    end
  end
end
