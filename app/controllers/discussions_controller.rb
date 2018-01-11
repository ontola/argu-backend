# frozen_string_literal: true

class DiscussionsController < AuthorizedController
  include NestedResourceHelper
  skip_before_action :check_if_registered

  private

  def authorize_action
    return super unless action_name == 'index'
    authorize parent_resource!, :index_children?, [controller_name, forum: parent_resource!]
  end

  def collection_options
    params
      .permit(:page)
      .to_h
      .merge(user_context: user_context)
      .to_options
  end
end
