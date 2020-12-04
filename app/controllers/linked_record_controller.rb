# frozen_string_literal: true

class LinkedRecordsController < EdgeableController
  def resource_by_id
    @resource_by_id ||= LinkedRecord.find_or_initialize_by_iri(Base64.decode64(params[:id]))
  end
end
