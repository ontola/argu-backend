class ForumPolicy < RestrictivePolicy
  class Scope < Scope
    attr_reader :context, :user, :scope, :session

    def initialize(context, scope)
      @context = context
      @profile = user.profile if user
      @scope = scope
    end

    delegate :user, to: :context
    delegate :session, to: :context

    def resolve
      t = Forum.arel_table

      scope.where(t[:visibility].eq(Forum.visibilities[:open]))
      scope.where(t[:id].in(user.profile.memberships_ids)) if user.present?
      scope
    end

  end

  def permitted_attributes
    attributes = super
    attributes << [:name, :bio, :bio_long, :tags, :featured_tags, :profile_photo, :remove_profile_photo,
                   :cover_photo, :remove_cover_photo, :cover_photo_attribution,
                   :cover_photo_original_w, {memberships_attributes: [:role, :id, :profile_id, :forum_id]},
                   :cover_photo_original_h, :cover_photo_box_w, :cover_photo_crop_x, :cover_photo_crop_y,
                   :cover_photo_crop_w, :cover_photo_crop_h, :cover_photo_aspect,
                   :uses_alternative_names, :questions_title, :questions_title_singular, :motions_title,
                   :motions_title_singular, :arguments_title, :arguments_title_singular] if update?
    attributes << [:visibility, :visible_with_a_link, :page_id] if change_owner?
    attributes
  end

  ######CRUD######
  def show?
    is_open? || has_access_token? || is_member? || is_manager? || super
  end

  def statistics?
    is_manager? || super
  end

  def managers?
    staff?
  end

  def groups?
    is_manager? || staff?
  end

  def new?
    create?
  end

  def create?
    super
  end

  def create_group?
    is_manager? || staff?
  end

  def edit?
    update?
  end

  def follow?
    is_open? || is_member? || is_manager? || staff?
  end

  def update?
    is_manager? || super
  end

  def invite?
    user && (is_open? || is_manager? || is_owner?)
  end

  def join?
    is_open? || has_access_token? || staff?
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
    true || user.present?
  end

  #######Attributes########
  def has_access_token?
    (session[:a_tokens] || []).find_index(record.access_token).present? && record.visible_with_a_link?
  end

  # Is the current user a member of the group?
  # @note This tells nothing about whether the user can make edits on the object
  def is_member?
    actor && actor.memberships.where(forum: record).present?
  end

  # Is the user a manager of the page or of the forum?
  def is_manager?
    _mems = user.profile if user
    user && (user.profile.page_memberships.where(page: record.page, role: PageMembership.roles[:manager]).present? || user.profile.memberships.where(forum: record, role: Membership.roles[:manager]).present?) || staff?
  end

  # This method exists to make sure that users who are in on an access token can't access other parts during the closed beta
  def is_open?
    @record.open?
  end

  def is_owner?
    user && record.memberships.where(role: Membership.roles[:owner], profile: user.profile).present? || staff?
  end

end
