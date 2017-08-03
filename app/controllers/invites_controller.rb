# frozen_string_literal: true
class InvitesController < AuthorizedController
  include NestedResourceHelper
  alias resource_by_id parent_resource
  alias authenticated_resource! resource_by_id

  def new
    respond_to do |format|
      format.js { render 'new.js' }
      format.html { render 'new' }
    end
  end

  private

  def authorize_action
    authorize authenticated_resource, :invite?
  end
end
