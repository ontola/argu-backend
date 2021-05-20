# frozen_string_literal: true

class MediaObjectsController < ParentableController
  private

  def authorize_action
    return super unless action_name == 'index'

    authorize parent_resource!, :index_children?, controller_class, user_context: user_context
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
