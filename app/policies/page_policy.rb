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
      page_memberships = PageMembership.arel_table
      scope.joins(:managerships).where(
        page_memberships[:profile_id]
          .eq(user.profile.id)
          .and(page_memberships[:role].eq(PageMembership.roles[:manager]))
      ).distinct
    end
  end

  module Roles
    delegate :open, :manager, :owner, to: :forum_policy

    def is_open?
      open if @record.open?
    end

    # Is the user a manager of the page or of the forum?
    def is_manager?
      (manager if user && user.profile.page_managerships.where(page: record).present?) ||
        is_owner? ||
        staff?
    end

    def is_owner?
      (owner if user && user.profile.id == record.try(:owner_id)) || staff?
    end

    def has_pages?
      (owner if user && user.profile.pages.present?) || staff?
    end
  end
  include Roles

  def permitted_attributes
    attributes = super
    if create?
      attributes.concat %i(bio tag_list last_accepted)
      attributes.append(profile_attributes: %i(id name profile_photo))
    end
    if new_record?
      attributes.append :visibility
      attributes.append(shortname_attributes: %i(shortname))
    end
    attributes.append :visibility if is_owner?
    attributes.concat %i(page_id repeat_name) if change_owner?
    attributes.append(profile_attributes: ProfilePolicy
                                            .new(context,
                                                 record.try(:profile) || Profile)
                                            .permitted_attributes)
    attributes.flatten
  end

  def permitted_tabs
    tabs = []
    tabs << :general if is_manager? || staff?
    tabs << :advanced << :managers if is_owner? || staff?
    tabs
  end

  def show?
    rule is_open?, is_manager?, super
  end

  def new?
    create? # user.present? || super
  end

  def create?
    rule pages_left?, super
  end

  def delete?
    destroy?
  end

  def destroy?
    rule is_manager?, super
  end

  def edit?
    update?
  end

  def index?
    rule has_pages?, staff?
  end

  def update?
    rule is_manager?, is_owner?, super
  end

  def list?
    rule record.closed?, show?
  end

  def list_members?
    rule is_owner?, staff?
  end

  # Whether the user can add (a specified) manager(s)
  # Only the owner can do this.
  def add_manager?(user)
    rule is_owner?
  end

  def pages_left?
    member if user && user.profile.pages.length < max_allowed_pages
  end

  def remove_manager?(user)
    rule is_owner?
  end

  def statistics?
    false
  end

  # TODO: Don't forget to remove the note that only argu can currently
  # transfer page ownership in forums/settings?tab=managers
  def transfer?
    rule is_owner?, staff?
  end

  def managers?
    rule is_owner?, staff?
  end

  def max_pages_reached?
    member if user && user.profile.pages.length >= max_allowed_pages
  end

  # Make sure that a tab param is actually accounted for
  # @return [String] The tab if it is considered valid
  def verify_tab(tab)
    tab ||= 'general'
    assert! permitted_tabs.include?(tab.to_sym), "#{tab}?"
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

  private

  def forum_policy
    ForumPolicy.new(context, Forum)
  end
end
