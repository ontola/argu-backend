# frozen_string_literal: true

class AnnouncementsController < ApplicationController
  include Common::Setup
  include Common::Index
  include Common::Show
  before_action :authorize_action

  private

  def authenticated_resource!
    @resource ||= Announcement.find(params[:id])
  end

  def authenticated_resource
    authenticated_resource! || raise(ActiveRecord::RecordNotFound)
  end

  def authorize_action
    authorize authenticated_resource, "#{params[:action].chomp('!')}?"
  end
end
