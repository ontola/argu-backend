# frozen_string_literal: true

module ActivePublishable
  module Action
    extend ActiveSupport::Concern

    included do
      define_action(
        :publish,
        type: [NS::SCHEMA[:Action], NS::ARGU[:PublishAction]],
        policy: :publish?,
        http_method: :put,
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
        }
      )
    end
  end
end
