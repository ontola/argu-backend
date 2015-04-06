class StaticPagePolicy < Struct.new(:user, :static_pages)
  attr_reader :context, :record

  def initialize(context, record)
    @context = context
    @record = record

    #raise Argu::NotLoggedInError.new(nil, record), "must be logged in" unless has_access_to_record?
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
    true
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
    true
  end

  def developers?
    user && user.profile.has_role?(:staff)
  end
end
