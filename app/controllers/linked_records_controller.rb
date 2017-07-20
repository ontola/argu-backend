# frozen_string_literal: true
class LinkedRecordsController < AuthorizedController
  include NestedResourceHelper

  def show
    if params[:id].nil?
      respond_to do |format|
        format.html { redirect_to url_for(authenticated_resource!.iri) }
        format.json_api { redirect_to url_for(authenticated_resource!) }
      end
    else
      respond_to do |format|
        format.html { redirect_to url_for(authenticated_resource!.iri) }
        format.json { respond_with_200(authenticated_resource!, :json) }
        format.json_api do
          render json: authenticated_resource!,
                 include: [
                   argument_collection: INC_NESTED_COLLECTION,
                   vote_event_collection: {members: {vote_collection: INC_NESTED_COLLECTION}}
                 ]
        end
      end
    end
  end

  private

  def current_forum; end

  def resource_by_id
    @_resource_by_id ||= params[:id].present? ? super : LinkedRecord.find_or_fetch_by_iri(params.fetch(:iri))
  end
end
