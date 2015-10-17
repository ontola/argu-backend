class PortalPolicy < Struct.new(:user, :portal)
  attr_reader :context, :record, :last_verdict, :last_enacted

  def initialize(context, record)
    #raise Pundit::NotAuthorizedError, "must be logged in" unless user
    @context = context
    @record = record
  end

  delegate :user, to: :context
  delegate :session, to: :context

  include RestrictivePolicy::Roles

  def assert!(assertion, query = nil)
    raise Pundit::NotAuthorizedError.new(record: record, query: query) unless assertion
  end

  def permitted_tabs
    tabs = []
    tabs.concat(%i(general documents setting announcements)) if staff?
    tabs
  end

  def home?
    user && user.profile.has_role?(:staff)
  end

  # Make sure that a tab param is actually accounted for
  # @return [String] The tab if it is considered valid
  def verify_tab(tab)
    tab ||= 'general'
    self.assert! self.permitted_tabs.include?(tab.to_sym), "#{tab}?"
    tab
  end

  class Scope
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
end
