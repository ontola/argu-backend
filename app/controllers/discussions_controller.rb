# frozen_string_literal: true

class DiscussionsController < ParentableController
  skip_before_action :check_if_registered

  private

  def authorize_action
    return super unless action_name == 'index'
    authorize parent_resource!, :index_children?, controller_name
  end

  def collection_options
    params
      .permit(:page)
      .to_h
      .merge(user_context: user_context)
      .to_options
  end

  def resource_by_id; end

  def resource_new_params
    HashWithIndifferentAccess.new(forum: parent_resource!)
  end
end
