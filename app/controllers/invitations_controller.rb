class InvitationsController < Devise::InvitationsController

  def new
    @forum = Forum.friendly.find params[:forum]
    super
  end

  def create
    @forum = Forum.friendly.find params[:forum]
    if @forum.present?
      authorize @forum, :invite?
      block = Proc.new do |resource|
        if (profile = resource.build_profile).save
          resource.profile_id = profile.id
          resource.profile.memberships.create(forum: @forum, role: Membership.roles[:member])
        end
      end
    end

    self.resource = invite_resource &block

    if resource.errors.empty?
      yield resource if block_given?
      if is_flashing_format? && self.resource.invitation_sent_at
        set_flash_message :notice, :send_instructions, :email => self.resource.email
      end
      respond_with resource, :location => after_invite_path_for(resource)
    else
      respond_with_navigational(resource) { render :new }
    end
  end

  def after_accept_path_for(resource)
    edit_profile_path(resource.profile)
  end
end