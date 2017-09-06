# frozen_string_literal: true

module Portal
  class SourcesController < EdgeTreeController
    def new
      render 'new', locals: {source: new_resource_from_params}
    end

    private

    def create_respond_failure_html(resource)
      render 'new',
             notifications: [{type: :error, message: 'Fout tijdens het aanmaken'}],
             locals: {source: resource}
    end

    def redirect_model_success(resource)
      page_source_path(resource.parent_model, resource)
    end

    def parent_resource
      @parent_resource ||= Shortname.find_resource(params[:page]) || Page.find_by(id: params.require(:source)[:page_id])
    end

    def resource_new_params
      HashWithIndifferentAccess.new(page: parent_resource!, publisher: current_user)
    end
  end
end
