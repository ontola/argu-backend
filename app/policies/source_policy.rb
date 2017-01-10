# frozen_string_literal: true
class SourcePolicy < EdgeTreePolicy
  class Scope < Scope
    attr_reader :context, :scope

    def initialize(context, scope)
      @context = context
      @profile = user.profile if user
      @scope = scope
    end

    delegate :user, to: :context
  end

  def permitted_attributes
    attributes = super
    attributes.concat %i(name iri_base shortname)
    attributes
  end

  def permitted_tabs
    tabs = []
    tabs.concat %i(general privacy groups) if is_manager? || staff?
    tabs
  end

  # #####Actions######
  def create?
    super
  end

  def settings?
    update?
  end

  def show?
    rule is_member?, is_manager?, super
  end

  def update?
    rule is_manager?, super
  end

  # Make sure that a tab param is actually accounted for
  # @return [String] The tab if it is considered valid
  def verify_tab(tab)
    tab ||= 'general'
    assert! permitted_tabs.include?(tab.to_sym), "#{tab}?"
    tab
  end
end
