# frozen_string_literal: true

require 'zip'

class ExportsController < ServiceController
  alias create_service_parent parent_resource!
  alias parent_edge parent_resource
  skip_before_action :redirect_edge_parent_requests

  private

  def authenticated_tree
    @_tree ||=
      case action_name
      when 'new', 'create', 'index'
        parent_edge&.self_and_ancestors
      else
        authenticated_edge&.self_and_ancestors
      end
  end

  def authorize_action
    return super unless action_name == 'index'
    authorize parent_resource!, :index_children?, controller_name
  end

  def index_respond_success_html
    render locals: {parent_edge: parent_edge}
  end

  def index_respond_success_js
    render locals: {parent_edge: parent_edge}
  end

  def permit_params
    {}
  end

  def redirect_model_success(resource)
    url_for([resource.edge, :exports, only_path: true])
  end

  def resource_new_params
    {user: current_user}
  end
end
