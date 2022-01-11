# frozen_string_literal: true

class CommentsController < EdgeableController
  include URITemplateHelper

  private

  def comments_tab
    authenticated_resource.parent.iri(fragment: :comments)
  end

  def redirect_location
    return super unless action_name == 'create' && authenticated_resource.persisted?

    comments_tab
  end

  def destroy_success_location
    comments_tab
  end
end
