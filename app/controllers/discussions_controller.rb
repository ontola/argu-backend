# frozen_string_literal: true
class DiscussionsController < AuthorizedController
  include NestedResourceHelper
  skip_before_action :check_if_registered

  def new
    @forum = parent_resource!
  end

  private

  def authorize_action
    raise 'Internal server error' unless action_name == 'new'
    authorize parent_resource!, :list?
  end

  def new_resource_from_params
    parent_resource!
      .edge
      .children
      .new(owner: nil,
           parent: parent_resource!.edge)
  end

  def resource_by_id
    parent_resource
  end
end
