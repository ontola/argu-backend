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

    def resolve
      t = Page.arel_table

      cond = t[:visibility].eq_any([Page.visibilities[:open], Page.visibilities[:closed]])
      if user.present?
        cond = cond.or(t[:id].in(user.profile.granted_record_ids('Page')
                                   .concat(user.profile.pages.pluck(:id))))
      end
      scope.where(cond)
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
    attributes.concat %i(page_id confirmation_string) if change_owner?
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
    tabs.concat %i(sources) if staff?
    tabs.concat %i(forums advanced) if is_owner? || staff?
    tabs
  end

  def show?
    rule is_open?, is_manager?, super
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

  def update?
    rule is_manager?, is_owner?, super
  end

  def list?
    rule record.closed?, show?
  end

  def list_members?
    rule is_owner?, staff?
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
