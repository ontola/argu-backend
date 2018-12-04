# frozen_string_literal: true

class StaticPagePolicy < Struct.new(:user, :static_pages)
  attr_reader :context, :record

  def initialize(context, record)
    @context = context
    @record = record
  end

  delegate :user, to: :context

  def home?
    true
  end

  def about?
    true
  end

  def dismiss_announcement?
    true
  end

  def product?
    true
  end

  def how_argu_works?
    true
  end

  def new_discussion?
    true
  end

  def team?
    true
  end

  def token?
    true
  end

  def governments?
    true
  end

  def persist_cookie?
    true
  end

  def developers?
    user.is_staff?
  end
end
