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
    return super if params[:id].present?
    @_resource_by_id ||= LinkedRecord.find_or_create_by!(iri: params[:iri]) do |linked_record|
      source = Source.find_by_iri!(params[:iri])
      linked_record.source = source
      linked_record.edge = Edge.new(parent: source.edge, user_id: 0)
      linked_record.page = source.page
    end
  end
end
