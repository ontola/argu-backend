# frozen_string_literal: true

class RedirectController < ApplicationController
  def show
    redirect_to resource.iri_path
  end

  private

  def resource # rubocop:disable Metrics/AbcSize
    case params[:resource]
    when 'Decision'
      Edge
        .find_by!(owner_id: params[:id], owner_type: 'Motion')
        .decisions
        .find_by(step: params[:step])
    when 'Argument'
      Edge.find_by(owner_id: params[:id], owner_type: 'ConArgument') ||
        Edge.find_by!(owner_id: params[:id], owner_type: 'ProArgument')
    else
      Edge.find_by!(owner_id: params[:id], owner_type: params[:resource])
    end
  end
end
