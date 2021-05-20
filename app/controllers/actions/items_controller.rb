# frozen_string_literal: true

module Actions
  class ItemsController < LinkedRails::Actions::ItemsController
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

    def redirect_action # rubocop:disable Metrics/AbcSize
      resource = parent_resource&.action(params[:id]&.to_sym, user_context)
      resource.label = params[:label]
      resource.target = LinkedRails.entry_point_class.new(
        parent: resource,
        url: RDF::URI(params[:location])
      )
      resource.instance_variable_set(:@iri, RDF::URI(request.original_url))
      resource
    end

    def redirect_action?
      parent_resource.is_a?(Page) && resource_id == 'redirect'
    end

    def requested_resource_parent; end
  end
end
