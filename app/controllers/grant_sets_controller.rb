# frozen_string_literal: true

class GrantSetsController < AuthorizedController
  include Common::Show

  private

  def resource_from_params
    @resource_from_params ||=
      if (/[a-zA-Z]/i =~ params[:id]).nil?
        GrantSet.find_by(id: params[:id])
      else
        GrantSet.find_by(title: params[:id])
      end
  end
end
