class ForumPolicy < RestrictivePolicy
  class Scope < Scope
    def resolve
      scope
    end

  end

  def permitted_attributes
    attributes = super
    attributes << [:name, :bio, :tags, :featured_tags, :profile_photo, :remove_profile_photo,
                   :cover_photo, :remove_cover_photo, :cover_photo_attribution,
                   :cover_photo_original_w, {memberships_attributes: [:role, :id, :profile_id, :forum_id]},
                   :cover_photo_original_h, :cover_photo_box_w, :cover_photo_crop_x, :cover_photo_crop_y,
                   :cover_photo_crop_w, :cover_photo_crop_h, :cover_photo_aspect] if update?
    attributes << [:visibility, :page_id] if change_owner?
    attributes
  end

  ######CRUD######
  def show?
    @record.open? || is_member? || is_manager? || super
  end

  def statistics?
    is_manager? || super
  end

  def managers?
    false
  end

  def new?
    create?
  end

  def create?
    super
  end

  def edit?
    update?
  end

  def update?
    is_manager? || super
  end

  def invite?
    @record.open? || is_manager? || is_owner?
  end

  def list?
    @record.closed? || show?
  end

  def add_question?
    is_member? || staff?
  end

  def add_motion?
    add_question?
  end

  def selector?
    true
  end

  #######Attributes########
  # Is the current user a member of the group?
  # @note This tells nothing about whether the user can make edits on the object
  def is_member?
    @user && @user.profile.memberships.where(forum: @record).present?
  end

  # Is the user a manager of the page or of the forum?
  def is_manager?
    _mems = @user.profile
    @user && (@user.profile.page_memberships.where(page: @record.page, role: PageMembership.roles[:manager]).present? || @user.profile.memberships.where(forum: @record, role: Membership.roles[:manager]).present?)
  end

  def is_owner?
    @user && @record.memberships.where(role: Membership.roles[:owner], profile: @user.profile).present? || staff?
  end

end
