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
      scope
    end

  end

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
    attributes << [:bio, :tag_list, {profile_attributes: [:id, :name, :profile_photo]}] if create?
    attributes << [:visibility, {shortname_attributes: [:shortname]}] if new_record?
    attributes << :visibility if is_owner?
    attributes << [:page_id, :repeat_name] if change_owner?
    attributes
  end

  def show?
    record.open? || is_manager? || super
  end

  def new?
    create?
  end

  def create?
    # This basically means everyone, change when users can report spammers/offenders and such
    user.present? || super
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

  #######Attributes########
  # Is the user a manager of the page or of the forum?
  def is_manager?
    user && user.profile.page_memberships.where(page: record, role: PageMembership.roles[:manager]).present? || is_owner? || staff?
  end

  def is_owner?
    user && user.profile.id == record.try(:owner_id) || staff?
  end
end
