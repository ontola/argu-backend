# frozen_string_literal: true

class RedirectController < ApplicationController
  def show
    redirect_to resource.iri_path
  end

  private

  def resource
    case params[:resource]
    when 'Decision'
      Edge
        .find_by!(owner_id: params[:id], owner_type: 'Motion')
        .decisions
        .joins('LEFT JOIN decisions ON decisions.id = edges.owner_id AND edges.owner_type = \'Decision\'')
        .find_by(step: params[:step])
    when 'Argument'
      Edge.find_by(owner_id: params[:id], owner_type: 'ConArgument') ||
        Edge.find_by!(owner_id: params[:id], owner_type: 'ProArgument')
    else
      Edge.find_by!(owner_id: params[:id], owner_type: params[:resource])
    end
  end
end
