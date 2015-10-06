class ForumPolicy < RestrictivePolicy
  class Scope < Scope
    attr_reader :context, :scope

    def initialize(context, scope)
      @context = context
      @profile = user.profile if user
      @scope = scope
    end

    delegate :user, to: :context
    delegate :session, to: :context

    def resolve
      t = Forum.arel_table

      cond = t[:visibility].eq(Forum.visibilities[:open])
      cond = cond.or(t[:id].in(user.profile.memberships_ids)) if user.present?
      scope.where(cond)
    end
  end

  module Roles
    def open
      1
    end

    def access_token
      2
    end

    def member
      3
    end

    def manager
      7
    end

    # This method exists to make sure that users who are in on an access token can't access other parts during the closed beta
    def is_open?
      open if @record.open?
    end

    def has_access_token?
      access_token if Set.new(record.m_access_tokens).intersect?(Set.new(session[:a_tokens])) && record.visible_with_a_link?
    end

    # Is the current user a member of the group?
    # @note This tells nothing about whether the user can make edits on the object
    def is_member?
      member if actor && actor.memberships.where(forum: record).count > 0
    end

    # Is the user a manager of the page or of the forum?
    # @note Trickles up
    def is_manager?
      _mems = user.profile if user
      [(manager if user && user.profile.managerships.where(forum: record).count > 0), is_owner?].compact.presence
    end

    # Currently, only the page owner is owner of a forum, managers of a page don't automatically become forum managers.
    def is_owner?
      #record.page.memberships.where(role: Membership.roles[:manager], profile: user.profile).present?
      owner if user && record.page.owner == user.profile
    end

    def is_manager_up?
      is_manager? || is_owner? || staff?
    end
  end
  include Roles

  module ForumRoles
    delegate :is_member?, :is_open?, :has_access_token?, :is_manager?, :is_owner?, :is_manager_up?, to: :forum_policy
    delegate :open, :access_token, :member, :manager, :owner, to: :forum_policy
  end

  def permitted_attributes
    attributes = super
    attributes << [:name, :bio, :bio_long, :tags, :featured_tags, :profile_photo, :remove_profile_photo,
                   :cover_photo, :remove_cover_photo, :cover_photo_attribution,
                   :cover_photo_original_w, {memberships_attributes: [:role, :id, :profile_id, :forum_id]},
                   :cover_photo_original_h, :cover_photo_box_w, :cover_photo_crop_x, :cover_photo_crop_y,
                   :cover_photo_crop_w, :cover_photo_crop_h, :cover_photo_aspect,
                   :uses_alternative_names, :questions_title, :questions_title_singular, :motions_title,
                   :motions_title_singular, :arguments_title, :arguments_title_singular,
                   :profile_id] if update?
    attributes << [:visibility, :visible_with_a_link, :page_id] if change_owner?
    attributes
  end

  def permitted_tabs
    tabs = []
    tabs << :general << :advanced << :groups << :projects << :banners if is_manager? || staff?
    tabs << :privacy << :managers if is_owner? || staff?
    tabs
  end

  ######Actions######
  def add_group_member?
    rule is_manager?, is_owner?, staff?
  end

  def create?
    super
  end

  def edit?
    update?
  end

  def follow?
    rule is_open?, is_member?, is_manager?, staff?
  end

  def groups?
    rule is_manager?, staff?
  end

  # Forum#index is for management, not to be confused with forum#discover
  def index?
    user && (user.profile.pages.length > 0 || user.profile.managerships.presence) || staff?
  end

  def invite?
    rule (user && (is_open? || is_manager?)), staff?
  end

  def join?
    rule is_open?, has_access_token?, is_manager?, staff?
  end

  def list?
    level = if @record.hidden?
      show?.presence || raise(ActiveRecord::RecordNotFound)
    else
      [(1 if @record.closed?), show?, is_open?, is_manager?, is_owner?]
    end
    rule level
  end

  def list_members?
    rule is_owner?, staff?
  end

  def managers?
    rule is_owner?, staff?
  end

  def new?
    rule create?
  end

  def show?
    rule is_open?, has_access_token?, is_member?, is_manager?, super
  end

  def statistics?
    super
  end

  def terminology?
    rule is_manager?, is_owner?, staff?
  end

  def update?
    rule is_manager?, super
  end

  # Whether the user can add (a specified) manager(s)
  # Only the owner can do this.
  def add_manager?(user)
    rule is_owner?
  end

  def remove_manager?(user)
    rule is_owner?
  end

  def add_motion?
    rule is_member?, staff?
  end

  def add_question?
    rule is_member?, staff?
  end

  def selector?
    true
  end

  # Make sure that a tab param is actually accounted for
  # @return [String] The tab if it is considered valid
  def verify_tab(tab)
    tab ||= 'general'
    self.assert! self.permitted_tabs.include?(tab.to_sym), "#{tab}?"
    tab
  end
end
