# frozen_string_literal: true

class GrantSetsController < AuthorizedController
  include Common::Show

  private

  def resource_by_id
    @resource_by_id ||=
      if (/[a-zA-Z]/i =~ params[:id]).nil?
        GrantSet.find_by(id: params[:id])
      else
        GrantSet.find_by(title: params[:id])
      end
  end
end
