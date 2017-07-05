# frozen_string_literal: true
class Portal::ForumsController < ApplicationController
  def new
    authorize new_resource_from_params, :new?
    render 'new', locals: {forum: new_resource_from_params}
  end

  def create
    authorize create_service.resource, :create?
    create_service.on(:create_forum_successful) do
      redirect_to portal_path
    end
    create_service.on(:create_forum_failed) do |forum|
      render 'new',
             notifications: [{type: :error, message: 'Fout tijdens het aanmaken'}],
             locals: {forum: forum}
    end
    create_service.commit
  end

  private

  def create_service
    @create_service ||= CreateForum.new(
      Page.find(permit_params[:page_id]).edge,
      attributes: permit_params,
      options: service_options
    )
  end

  def new_resource_from_params
    @resource ||= Shortname.find_resource(params[:page])
                           .edge
                           .children
                           .new(owner: Forum.new(page: params[:page]))
                           .owner
  end

  def permit_params
    params.require(:forum).permit :name, :shortname,
                                  :profile_photo, :cover_photo, :page_id,
                                  shortname_attributes: [:shortname]
  end

  def service_options
    {
      creator: current_actor.actor,
      publisher: current_user
    }
  end
end
