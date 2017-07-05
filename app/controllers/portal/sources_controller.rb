# frozen_string_literal: true
module Portal
  class SourcesController < PortalBaseController
    def new
      authorize new_resource_from_params, :new?
      render 'new', locals: {source: new_resource_from_params}
    end

    def create
      authorize create_service.resource, :create?
      create_service.on(:create_source_successful) do
        redirect_to portal_path
      end
      create_service.on(:create_source_failed) do |source|
        render 'new',
               notifications: [{type: :error, message: 'Fout tijdens het aanmaken'}],
               locals: {source: source}
      end
      create_service.commit
    end

    private

    def create_service
      @create_service ||= CreateSource.new(
        get_parent_resource.edge,
        attributes: permit_params,
        options: service_options
      )
    end

    def get_parent_resource
      @get_parent_resource ||= Shortname.find_resource(params[:page]) || Page.find(params.require(:source)[:page_id])
    end

    def new_resource_from_params
      @resource ||= get_parent_resource
                      .edge
                      .children
                      .new(owner: Source.new(page: get_parent_resource))
                      .owner
    end

    def permit_params
      params
        .require(:source)
        .permit(*policy(new_resource_from_params).permitted_attributes)
    end

    def service_options(options = {})
      {
        creator: current_actor.actor,
        publisher: current_user,
        uuid: a_uuid,
        client_id: request.session.id
      }.merge(options)
    end
  end
end
