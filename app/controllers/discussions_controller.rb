class DiscussionsController < ApplicationController
  include NestedResourceHelper

  def new
    @forum = get_parent_resource
    authorize get_parent_resource, :list?
  end
end
