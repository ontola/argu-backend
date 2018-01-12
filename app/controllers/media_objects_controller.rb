# frozen_string_literal: true

class MediaObjectsController < ParentableController
  skip_before_action :check_if_registered, only: :index

  private

  def authorize_action
    return super unless action_name == 'index'
    authorize parent_resource, :index_children?, [controller_name, about: parent_resource]
  end

  def index_collection_association
    'attachment_collection'
  end
end
