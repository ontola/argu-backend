# frozen_string_literal: true

class BannersController < AuthorizedController
  include NestedResourceHelper

  def new
    render 'forums/settings',
           locals: {
             banner: authenticated_resource!,
             resource: authenticated_context,
             tab: 'banners/new',
             active: 'banners'
           }
  end

  def create
    create_service.on(:create_banner_successful) do |banner|
      respond_to do |format|
        format.html do
          redirect_to settings_forum_path(banner.forum, tab: :banners),
                      notice: t('type_create_success', type: t('banners.type')).capitalize
        end
      end
    end
    create_service.on(:create_banner_failed) do |banner|
      respond_to do |format|
        format.html do
          render 'forums/settings',
                 locals: {
                   banner: banner,
                   tab: 'banners/new',
                   active: 'banners'
                 }
        end
      end
    end
    create_service.commit
  end

  def edit
    render 'forums/settings',
           locals: {
             banner: authenticated_resource,
             resource: authenticated_resource.forum,
             tab: 'banners/edit',
             active: 'banners'
           }
  end

  def update
    update_service.on(:update_banner_successful) do |banner|
      respond_to do |format|
        format.html { redirect_to settings_forum_path(banner.forum, tab: 'banners') }
      end
    end
    update_service.on(:update_banner_failed) do |banner|
      respond_to do |format|
        format.html do
          render 'forums/settings',
                 locals: {
                   banner: banner,
                   tab: 'banners/edit',
                   active: 'banners'
                 }
        end
      end
    end
    update_service.commit
  end

  def destroy
    destroy_service.on(:destroy_banner_successful) do |banner|
      respond_to do |format|
        format.html do
          flash[:success] = t('type_destroyed', type: t('banners.type'))
          redirect_to settings_forum_path(banner.forum, tab: :banners)
        end
      end
    end
    destroy_service.on(:destroy_banner_failed) do |banner|
      respond_to do |format|
        format.html do
          flash[:error] = t('type_destroyed_failed', type: t('banners.type'))
          redirect_to settings_forum_path(banner.forum, tab: :banners)
        end
      end
    end
    destroy_service.commit
  end

  private

  def new_resource_from_params
    controller_name
      .classify
      .constantize
      .new resource_new_params
  end

  def permit_params
    params
      .require(:banner)
      .permit(*policy(resource_by_id || new_resource_from_params || Banner).permitted_attributes)
  end
end
