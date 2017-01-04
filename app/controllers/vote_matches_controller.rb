# frozen_string_literal: true
class VoteMatchesController < AuthorizedController
  def show
    respond_to do |format|
      format.json_api do
        render json: authenticated_resource
      end
    end
  end

  private

  def resource_by_id
    return super if params[:page_id].nil? && params[:user_id].nil? || @_resource_by_id.present?
    profile = if params[:page_id].present?
                Page.find_via_shortname(params[:page_id]).profile
              else
                User.find_via_shortname(params[:user_id]).profile
              end
    @_resource_by_id ||= List.find_by(creator: profile, shortname: params[:id])
  end
end
