# frozen_string_literal: true
class FavoritesController < ApplicationController
  include NestedResourceHelper
  before_action :check_if_registered
  skip_after_action :verify_authorized, only: :destroy

  def create
    @favorite = current_user.favorites.find_or_initialize_by(edge: get_parent_edge)
    authorize @favorite, :create?

    if @favorite.save
      respond_to do |format|
        format.html do
          flash[:success] = t('type_create_success', type: t('group_memberships.type'))
          redirect_back(fallback_location: root_path)
        end
      end
    else
      respond_to do |format|
        format.html do
          flash[:error] = t('errors.general')
          redirect_back(fallback_location: root_path)
        end
      end
    end
  end

  def destroy
    @favorite = current_user.favorites.find_by!(edge: get_parent_edge)
    authorize @favorite, :destroy?

    if @favorite.destroy
      respond_to do |format|
        format.html do
          flash[:success] = t('type_destroy_success', type: t('group_memberships.type'))
          redirect_back(fallback_location: root_path)
        end
      end
    else
      respond_to do |format|
        format.html do
          flash[:error] = t('errors.general')
          redirect_back(fallback_location: root_path)
        end
      end
    end
  end

  private

  def check_if_registered
    return unless current_user.guest?
    raise Argu::NotAUserError.new(forum: get_parent_edge.owner,
                                  r: url_for(get_parent_edge.owner))
  end
end
