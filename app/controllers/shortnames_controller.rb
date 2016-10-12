# frozen_string_literal: true
class ShortnamesController < ApplicationController
  include NestedResourceHelper

  def new
    authorize new_resource_from_params, :create?

    render_settings
  end

  def create
    authorize new_resource_from_params, :create?

    redirect_or_render(new_resource_from_params.update(permit_params))
  rescue ActiveRecord::RecordNotUnique
    handle_record_not_unique
  end

  def edit
    authorize resource_by_id, :edit?

    render_settings(:edit)
  end

  def update
    authorize resource_by_id, :update?

    redirect_or_render(resource_by_id.update(permit_params), :edit)
  rescue ActiveRecord::RecordNotUnique
    handle_record_not_unique(:edit)
  end

  def destroy
    authorize resource_by_id, :destroy?

    flash[:error] = resource_by_id.errors.full_messages unless resource_by_id.destroy
    forum_settings_redirect
  end

  private

  def forum_settings_redirect
    redirect_to settings_forum_path(@forum, tab: 'shortnames')
  end

  def handle_record_not_unique(tab = :new)
    resource_by_id.errors.add :owner, t('activerecord.errors.record_not_unique')
    render_settings(tab)
  end

  def new_resource_from_params
    @forum ||= get_parent_resource
    @resource ||= Shortname.new(forum: @forum)
  end

  def redirect_or_render(result, tab = :new)
    if result
      forum_settings_redirect
    else
      render_settings(tab)
    end
  end

  def render_settings(tab = :new)
    render 'forums/settings',
           locals: {
             tab: "shortnames/#{tab}",
             active: 'shortnames',
             shortname: @resource,
             resource: @resource.forum
           }
  end

  def resource_by_id
    @resource ||= Shortname.find(params[:id])
    @forum ||= @resource.forum
    @resource
  end

  def permit_params
    p = params
          .require(:shortname)
          .permit(*policy(resource_by_id || new_resource_from_params).permitted_attributes)
    p['owner_type'] = nil unless %w(Project Question Motion Argument Comment).include?(p['owner_type'])
    p
  end
end
