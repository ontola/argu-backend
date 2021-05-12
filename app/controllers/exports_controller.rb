# frozen_string_literal: true

require 'zip'

class ExportsController < ServiceController
  skip_before_action :redirect_index_requests

  private

  def authenticated_tree
    @authenticated_tree ||=
      case action_name
      when 'new', 'create', 'index'
        parent_resource&.self_and_ancestors
      else
        authenticated_resource&.self_and_ancestors
      end
  end

  def authorize_action
    return authorize parent_resource!, :show? if form_action?
    return super unless action_name == 'index'

    authorize parent_resource!, :index_children?, controller_name, user_context: user_context
  end

  def index_collection
    parent_resource!.export_collection(collection_options)
  end

  def permit_params
    {}
  end

  def redirect_location
    export_iri(authenticated_resource.edge)
  end

  def resource_new_params
    {user: current_user, edge: parent_resource!}
  end
end
