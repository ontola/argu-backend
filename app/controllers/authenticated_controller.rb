
class AuthenticatedController < ApplicationController
  before_action :check_if_registered,
                only: %i(new create delete destroy edit update)
  before_action :check_if_member,
                only: %i(new create delete destroy edit update)

private
  def check_if_member
    if current_profile.present? &&
        !(current_profile.member_of?(authenticated_context) ||
            current_profile.owner_of(authenticated_context) ||
        policy(current_profile.profileable).staff?)
      raise Argu::NotAMemberError.new(forum: authenticated_context,
                                      r: redirect_url)
    end
  end

  def check_if_registered
    if current_profile.blank?
      resource = authenticated_resource
      authorize resource, :show?
      raise Argu::NotAUserError.new(authenticated_context,
                                    redirect_url)
    end
  end

  def authenticated_resource
    authenticated_resource! or raise ActiveRecord::RecordNotFound
  end

  def authenticated_resource!
    if params[:action] == 'new'
      controller_name
          .classify
          .constantize
          .new forum: context_by_param
    else
      controller_name
          .classify
          .constantize
          .find_by id: params[:id]
    end
  end

  def authenticated_context
    if authenticated_resource!.present?
      authenticated_resource.forum
    else
      context_by_param
    end
  end

  def context_by_param
    Forum.find_via_shortname params[:forum_id]
  end

  def redirect_url
    [request.path, request.query_string].reject(&:blank?).join('?')
  end

  def _route?
    ![:new, :create].include? params[:action]
  end
end
