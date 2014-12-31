class Users::InvitationsController < Devise::InvitationsController

  def after_accept_path_for(resource)
    edit_profile_path(resource.profile)
  end
end