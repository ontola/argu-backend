
class AuthenticatedController < ApplicationController
  before_action :check_if_registered,
                only: %i(new create delete destroy edit update)
  before_action :check_if_member,
                only: %i(new create delete destroy edit update)
  before_action :authorize_show, only: :show

  rescue_from Argu::NotAUserError do |exception|
    @resource ||= User.new(r: exception.r, shortname: Shortname.new)
    respond_to do |format|
      format.js  do
        render 'devise/sessions/new',
               status: 401,
               layout: false,
               locals: {
                   resource: @resource,
                   resource_name: :user,
                   devise_mapping: Devise.mappings[:user],
                   r: exception.r
               }
      end
      format.html do
        redirect_to new_user_session_path(r: exception.r)
      end
    end
  end

  rescue_from Argu::NotAMemberError do |exception|
    authorize exception.forum, :join?
    respond_to do |format|
      format.html { render template: 'forums/join', locals: { forum: exception.forum, r: exception.r } }
      format.js { render partial: 'forums/join', layout: false, locals: { forum: exception.forum, r: exception.r } }
      format.json { render json: exception.body, status: 403 }
    end
  end

private
  def authorize_show
    authorize authenticated_resource!, :show?
  end

  def check_if_member
    if current_profile.present? &&
        !(current_profile.member_of?(authenticated_context) ||
            current_profile.owner_of(authenticated_context) ||
        current_user.profile.has_role?(:staff))
      raise Argu::NotAMemberError.new(forum: authenticated_context,
                                      r: redirect_url)
    end
  end

  def check_if_registered
    if current_profile.blank?
      raise Argu::NotAUserError.new(authenticated_context,
                                    redirect_url)
    end
  end

  def authenticated_resource
    authenticated_resource! or raise ActiveRecord::RecordNotFound
  end

  def authenticated_resource!
    if params[:action] == 'new' || params[:action] == 'create'
      controller_name
          .classify
          .constantize
          .new forum: tenant_by_param
    else
      controller_name
          .classify
          .constantize
          .find_by id: params[:id]
    end
  end

  def authenticated_context
    if authenticated_resource!.present?
      authenticated_resource!.forum
    else
      tenant_by_param
    end
  end

  def tenant_by_param
    Forum.find_via_shortname params[:forum_id]
  end

  def redirect_url
    [request.path, request.query_string].reject(&:blank?).join('?')
  end

  def _route?
    ![:new, :create].include? params[:action]
  end
end
