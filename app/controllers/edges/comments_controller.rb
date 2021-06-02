# frozen_string_literal: true

class CommentsController < EdgeableController
  include UriTemplateHelper

  private

  def redirect_location
    return super unless action_name == 'create' && authenticated_resource.persisted?

    authenticated_resource.parent.iri
  end

  def destroy_success_location
    authenticated_resource.parent.iri
  end
end
