# frozen_string_literal: true
class Portal::ForumsController < EdgeTreeController
  private

  def parent_resource
    Page.find_via_shortname_or_id(params[:page] || params[:forum][:page_id])
  end

  def resource_new_params
    HashWithIndifferentAccess.new(
      page: parent_resource!
    )
  end
end
