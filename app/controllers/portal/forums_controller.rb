# frozen_string_literal: true
class Portal::ForumsController < EdgeTreeController
  private

  def current_forum; end

  def parent_resource(_opts = {})
    Page.find_via_shortname_or_id!(params[:page] || params[:forum][:page_id])
  end

  def resource_new_params
    HashWithIndifferentAccess.new(
      page: parent_resource
    )
  end
end
