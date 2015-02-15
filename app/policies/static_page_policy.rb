class StaticPagePolicy < Struct.new(:user, :static_pages)
  attr_reader :context, :user, :record, :session

  def initialize(context, record)
    @context = context
    @record = record

    #raise Argu::NotLoggedInError.new(nil, record), "must be logged in" unless has_access_to_platform?
  end

  delegate :user, to: :context
  delegate :session, to: :context

  def home?
    true
  end

  def about?
    true
  end

  def product?
    user && user.profile.has_role?(:staff)
  end

  def sign_in_modal?
    true
  end

  def how_argu_works?
    true
  end

  def team?
    true
  end

  def governments?
    user && user.profile.has_role?(:staff)
  end

  def developers?
    user && user.profile.has_role?(:staff)
  end
end
