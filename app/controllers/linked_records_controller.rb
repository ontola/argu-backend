# frozen_string_literal: true

class LinkedRecordsController < ParentableController
  private

  def include_show
    [
      argument_collection: inc_nested_collection,
      vote_event_collection: {members: {vote_collection: inc_nested_collection}}
    ]
  end

  def resource_by_id
    @_resource_by_id ||= params[:id].present? ? super : LinkedRecord.find_or_fetch_by_iri(params.fetch(:iri))
  rescue ActiveRecord::RecordNotFound
    nil
  end

  def show_respond_success_html(resource)
    redirect_to url_for(resource.record_iri)
  end

  def show_respond_success_serializer(resource, _format)
    return super unless params[:id].nil?
    redirect_to url_for(resource)
  end
end
