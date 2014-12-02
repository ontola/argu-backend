class ForumPolicy < RestrictivePolicy
  class Scope < Scope
    def resolve
      scope
    end

  end

  def permitted_attributes
    attributes = super
    attributes << [:name, :bio, :tags, :tag_list, :profile_photo, :cover_photo, :cover_photo_original_w,
                   {memberships_attributes: [:role, :id, :profile_id, :forum_id]},
                   :cover_photo_original_h, :cover_photo_box_w, :cover_photo_crop_x, :cover_photo_crop_y,
                   :cover_photo_crop_w, :cover_photo_crop_h, :cover_photo_aspect] if update?
    attributes << :page_id if change_owner?
  end

  ######CRUD######
  def show?
    #(user && user.profile.memberships.where(forum: record).present?) || super
    true || super # Until forum scope settings are implemented
  end

  def show_children?
    member? || staff?
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
    (user && user.profile.memberships.where(forum: record, role: Membership.roles[:manager]).present?) || super
  end

  def add_question?
    false || update?
  end

  def change_owner?
    staff?
  end

  #######Attributes########
  # Is the current user a member of the group?
  # @note This tells nothing about whether the user can make edits on the object
  def member?
    user && user.profile.memberships.where(forum: record).present?
  end

end
