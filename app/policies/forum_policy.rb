# frozen_string_literal: true
class ForumPolicy < EdgeTreePolicy
  class Scope < Scope
    attr_reader :context, :scope

    def initialize(context, scope)
      @context = context
      @profile = user.profile if user
      @scope = scope
    end

    delegate :user, to: :context

    def resolve
      t = Forum.arel_table

      cond = t[:visibility].eq(Forum.visibilities[:open])
      cond = cond.or(t[:id].in(user.profile.joined_forum_ids)) if user.present?
      scope.where(cond)
    end
  end

  def is_open?
    open if @record.open?
  end

  def permitted_attributes
    attributes = super
    attributes.concat %i(name bio bio_long tags featured_tags profile_id) if update?
    attributes.concat %i(visibility visible_with_a_link page_id) if change_owner?
    attributes.append(memberships_attributes: %i(role id profile_id forum_id))
    append_default_photo_params(attributes)
    attributes
  end

  def permitted_tabs
    tabs = []
    tabs.concat %i(general advanced shortnames banners) if is_manager? || staff?
    tabs.concat %i(privacy grants) if is_owner? || staff?
    tabs
  end

  # #####Actions######
  def create?
    super
  end

  def edit?
    update?
  end

  def follow?
    rule is_open?, is_member?, is_manager?, staff?
  end

  def groups?
    rule is_manager?, staff?
  end

  # Forum#index is for management, not to be confused with forum#discover
  def index?
    user&.forum_management? || staff?
  end

  def join?
    rule is_open?, has_access_token?, is_manager?, staff?
  end

  def list?
    level =
      if @record.hidden?
        show?.presence || raise(ActiveRecord::RecordNotFound)
      else
        [(1 if @record.closed?), show?, is_open?, is_manager?, is_owner?]
      end
    rule level
  end

  def list_members?
    rule is_owner?, staff?
  end

  def managers?
    rule is_owner?, staff?
  end

  def new?
    rule create?
  end

  def settings?
    update?
  end

  def show?
    rule is_open?, has_access_token?, is_member?, is_manager?, super
  end

  def statistics?
    super
  end

  def update?
    rule is_manager?, super
  end

  def add_motion?
    rule is_member?, staff?
  end

  def add_question?
    rule is_member?, staff?
  end

  # Make sure that a tab param is actually accounted for
  # @return [String] The tab if it is considered valid
  def verify_tab(tab)
    tab ||= 'general'
    assert! permitted_tabs.include?(tab.to_sym), "#{tab}?"
    tab
  end
end
