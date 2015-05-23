class PagePolicy < RestrictivePolicy
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
      page = Page.arel_table
      page_memberships = PageMembership.arel_table
      cond = page[:owner_id].eq(user.profile.id)
      cond = page.join(page_memberships).on(page[:id].eq(page_memberships[:page])).where(page_memberships[:role].eq(PageMembership.roles[:manager]))
      #scope.where(cond)
      scope.joins(:managerships).where(
          page_memberships[:profile_id].eq(user.profile.id).and(page_memberships[:role].eq(PageMembership.roles[:manager]))
      ).distinct
    end

  end

  module Roles
    # Is the user a manager of the page or of the forum?
    def is_manager?
      user && user.profile.page_memberships.where(page: record, role: PageMembership.roles[:manager]).present? || is_owner? || staff?
    end

    def is_owner?
      user && user.profile.id == record.try(:owner_id) || staff?
    end
  end
  include Roles

  def initialize(context, record)
    @context = context
    @record = record

    # Note: Needs to be overridden since RestrictivePolicy checks for
    #       record-level access
    unless has_access_to_platform?
      raise Argu::NotLoggedInError.new(nil, record), 'must be logged in'
    end
  end

  def permitted_attributes
    attributes = super
    attributes << [:bio, :tag_list, :last_accepted, profile_attributes: [:id, :name, :profile_photo]] if create?
    attributes << [:visibility, shortname_attributes: [:shortname]] if new_record?
    attributes << :visibility if is_owner?
    attributes << [:page_id, :repeat_name] if change_owner?
    attributes << [profile_attributes: ProfilePolicy.new(context, record.profile).permitted_attributes]
    attributes.flatten
  end

  def permitted_tabs
    tabs = []
    tabs << :general if is_manager? || staff?
    tabs << :advanced << :managers if is_owner? || staff?
    tabs
  end

  def show?
    record.open? || is_manager? || super
  end

  def new?
    user.present? || super
  end

  def create?
    # This basically means everyone, change when users can report spammers/offenders and such
    !max_pages_reached? || super
  end

  def delete?
    destroy?
  end

  def destroy?
    is_manager? || super
  end

  def edit?
    update?
  end

  def update?
    is_manager? || super
  end

  def list?
    record.closed? || show?
  end

  def list_members?
    is_owner? || staff?
  end

  # Whether the user can add (a specified) manager(s)
  # Only the owner can do this.
  def add_manager?(user)
    is_owner?
  end

  def remove_manager?(user)
    is_owner?
  end

  def statistics?
    false
  end

  # TODO: Don't forget to remove the note that only argu can currently
  # transfer page ownership in forums/settings?tab=managers
  def transfer?
    staff?
  end

  def managers?
    is_owner? || staff?
  end

  def max_pages_reached?
    user && user.profile.pages.length >= max_allowed_pages
  end

  # Make sure that a tab param is actually accounted for
  # @return [String] The tab if it is considered valid
  def verify_tab(tab)
    tab ||= 'general'
    self.assert! self.permitted_tabs.include?(tab.to_sym)
    tab
  end

  #######Attributes########

  def max_allowed_pages
    if staff?
      Float::INFINITY
    elsif user
      1
    else
      0
    end
  end
end
