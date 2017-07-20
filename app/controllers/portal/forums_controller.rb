# frozen_string_literal: true
class Portal::ForumsController < EdgeTreeController
  private

  def current_forum; end

  def get_parent_edge
    get_parent_resource.edge
  end

  def get_parent_resource
    Page.find_via_shortname!(params[:page] || params[:forum][:page_id])
  end

  def resource_new_params
    HashWithIndifferentAccess.new(
      page: get_parent_resource
    )
  end
end
