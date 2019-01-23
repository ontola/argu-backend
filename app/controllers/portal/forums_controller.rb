# frozen_string_literal: true

# @todo remove this controller and it's routes after release of FE2.0

class Portal::ForumsController < EdgeableController
  def new
    redirect_to new_iri(parent_resource, :forums)
  end

  private

  def parent_resource
    Page.find_via_shortname_or_id(params[:page] || params[:page_id])
  end
end
