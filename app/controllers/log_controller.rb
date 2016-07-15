# frozen_string_literal: true
class LogController < AuthorizedController
  include NestedResourceHelper
  alias_method :resource_by_id, :get_parent_resource

  def log
    respond_to do |format|
      format.html { render 'log', locals: {resource: resource_by_id} }
      format.json { render json: resource_by_id.activities }
    end
  end
end
