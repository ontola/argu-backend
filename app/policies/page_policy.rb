class PagePolicy < RestrictivePolicy
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
      scope
    end

  end

  def permitted_attributes
    attributes = super
    attributes << [:bio, :tag_list, {profile_attributes: [:id, :name, :profile_photo]}] if create?
    attributes << :web_url if new_record? || staff?
    attributes << :page_id if change_owner?
    attributes
  end

  ######CRUD######
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

  def statistics?
    false
  end

  def managers?
    is_owner?
  end

  #######Attributes########
  # Is the user a manager of the page or of the forum?
  def is_manager?
    user && user.profile.page_memberships.where(page: record, role: PageMembership.roles[:manager]).present? || is_owner? || staff?
  end

  def is_owner?
    user && user.profile.id == record.owner_id || staff?
  end

  def new_record?
    record == Page || record.new_record?
  end

end
