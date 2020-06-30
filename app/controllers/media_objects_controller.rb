# frozen_string_literal: true

class MediaObjectsController < ParentableController
  skip_before_action :check_if_registered, only: :index

  private

  def authorize_action
    return super unless action_name == 'index'

    authorize parent_resource, :index_children?, controller_name, user_context: user_context
  end

  def current_forum
    @current_forum ||= parent_resource.try(:ancestor, :forum)
  end

  def collection_from_parent_name
    return super if params[:used_as].blank?

    "#{params[:used_as]}_collection"
  end

  def resource_new_params
    {
      about: parent_resource,
      used_as: params[:used_as]
    }
  end
end
