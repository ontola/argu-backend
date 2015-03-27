class Users::InvitationsController < Devise::InvitationsController

  def new
    @forum = Forum.find_via_shortname params[:forum]
    super
  end

  def create
    @forum = Forum.find_via_shortname params[:forum]
    authorize @forum, :invite?
    super
  end

  def update
    super
  end

  def after_accept_path_for(resource)
    edit_profile_path(resource)
  end

  def after_invite_path_for(resource)
    forum_path(@forum) || root_path
  end

  def invite_params
    super.merge(access_tokens: [@forum.try(:access_token)])
  end
end