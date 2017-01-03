# frozen_string_literal: true
class LinkedRecordsController < AuthorizedController
  include NestedResourceHelper

  def show
    if params[:id].nil?
      redirect_to url_for(resource_by_id)
    else
      render json: authenticated_resource!, include: [:arguments, :top_arguments_pro, :top_arguments_con, :vote_events]
    end
  end

  private

  def resource_by_id
    @_resource_by_id ||= params[:id].present? ? super : LinkedRecord.find_or_fetch_by_iri(params.fetch(:iri))
  end
end
