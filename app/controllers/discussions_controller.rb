# frozen_string_literal: true
class DiscussionsController < ApplicationController
  include NestedResourceHelper

  def new
    @forum = get_parent_resource
    authorize get_parent_resource, :list?
  end

  private

  def resource_by_id
    get_parent_resource
  end
end
