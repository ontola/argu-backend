# frozen_string_literal: true
class PagePolicy < EdgeTreePolicy
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
      scope.where(id: user&.profile&.page_ids)
    end
  end

  module Roles
    def is_creator?
      super if persisted_edge
    end

    def is_moderator?
      super if persisted_edge
    end

    def is_manager?
      super if persisted_edge
    end

    def is_owner?
      super if persisted_edge
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

  def is_open?
    open if @record.open?
  end

  def permitted_tabs
    tabs = []
    tabs.concat %i(profile groups) if is_manager? || staff?
    tabs.concat %i(grants forums advanced) if is_owner? || staff?
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

  # Whether the user can add group_member(s)
  # Only the owner can do this.
  def add_group_member?
    rule is_owner?
  end

  def pages_left?
    member if user && user.profile.pages.length < UserPolicy.new(context, user).max_allowed_pages
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

  # Make sure that a tab param is actually accounted for
  # @return [String] The tab if it is considered valid
  def verify_tab(tab)
    tab ||= 'profile'
    assert! permitted_tabs.include?(tab.to_sym), "#{tab}?"
    tab
  end
end
