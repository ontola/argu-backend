# frozen_string_literal: true

module Actions
  class ItemsController < LinkedRails::Actions::ItemsController
    skip_before_action :check_if_registered
    before_action :authorize_action

    private

    def authorize_action
      skip_verify_policy_scoped(true)
      if parent_id_from_params.present?
        authorize parent_resource!, :show?
      else
        skip_verify_policy_authorized(true)
      end
    end

    def current_forum; end

    def index_includes
      []
    end

    def requested_resource
      resource = super
      return resource unless parent_resource.is_a?(Page) && resource_id == 'redirect'

      resource.label = params[:label]
      resource.target = {id: RDF::URI(params[:location])}
      resource.instance_variable_set(:@iri, RDF::URI(request.original_url))
      resource
    end

    def resource_by_id_parent; end

    def resource_from_params
      requested_resource
    end
  end
end
