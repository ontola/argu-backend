# frozen_string_literal: true

class MediaObjectsController < ParentableController
  skip_before_action :check_if_registered, only: :index

  private

  def authorize_action
    return super unless action_name == 'index'
    authorize parent_resource, :index_children?, controller_name
  end

  def current_forum
    @current_forum ||= parent_resource.try(:ancestor, :forum)
  end

  def index_collection_name
    return super if params[:used_as].blank?
    "#{params[:used_as]}_collection"
  end
end
