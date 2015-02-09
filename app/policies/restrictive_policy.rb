class RestrictivePolicy
  include AccessTokenHelper
  attr_reader :context, :user, :record, :session

  def initialize(context, record)
    @context = context
    @record = record

    raise Argu::NotLoggedInError.new(nil, record), "must be logged in" unless has_access_to_platform?
  end

  delegate :user, to: :context
  delegate :session, to: :context

  def permitted_attributes
    attributes = []
    attributes << :web_url if web_url?
    attributes << :is_trashed if trash?
    attributes
  end

  def staff?
    user && user.profile.has_role?(:staff)
  end

  def change_owner?
    staff?
  end

  def create?
    staff?
  end

  def destroy?
    staff?
  end

  def edit?
    update?
  end

  def follow?
    staff?
  end

  def index?
    staff?
  end

  def logged_in?
    user.present?
  end

  def new?
    create?
  end

  # Used when an item displays nested content, therefore this should use the heaviest restrictions
  def show?
    staff?
  end

  def statistics?
    staff?
  end

  # Used when items won't include nested content, this is a less restrictive version of show?
  def list?
    staff?
  end

  # Move items between forums or converting items
  def move?
    staff?
  end

  def trash?
    staff?
  end

  def update?
    staff?
  end

  def vote?
    staff?
  end

  # Can the current user change the forum web_url? (currently a subdomain)
  def web_url?
    staff?
  end

  def is_creator?
    record.creator == user.profile
  end

  def has_access_to_platform?
    user || has_access_token_access_to(record)
  end

  def scope
    Pundit.policy_scope!(context, record.class)
  end

  class Scope
    include AccessTokenHelper
    attr_reader :context, :user, :scope, :session

    def initialize(context, scope)
      @context = context
      @profile = user.profile if user
      @scope = scope
    end

    delegate :user, to: :context
    delegate :session, to: :context

    def resolve
      scope if staff?
    end

    def staff?
      user && profile.has_role?(:staff)
    end
  end

end

