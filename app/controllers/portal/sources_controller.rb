# frozen_string_literal: true
module Portal
  class SourcesController < EdgeTreeController
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

    def parent_resource
      @parent_resource ||= Shortname.find_resource(params[:page]) || Page.find_by(id: params.require(:source)[:page_id])
    end

    def resource_new_params
      HashWithIndifferentAccess.new(page: parent_resource!, publisher: current_user)
    end
  end
end
