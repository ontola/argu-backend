# frozen_string_literal: true

module ActivePublishable
  module Controller
    extend ActiveSupport::Concern

    included do
      has_resource_action(
        :publish,
        type: [NS.schema.Action, NS.argu[:PublishAction]],
        policy: :publish?,
        http_method: :put,
        image: 'fa-send',
        target_url: lambda {
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

    def create_success
      return super if resource_was_published?

      respond_with_redirect(
        location: create_success_location,
        meta: create_meta,
        notice: active_response_success_message,
        status: :created
      )
    end
  end
end
