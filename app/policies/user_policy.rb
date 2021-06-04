# frozen_string_literal: true

class UserPolicy < RestrictivePolicy
  class Scope < Scope
    def resolve
      scope
    end
  end
  include ChildOperations

  permit_nested_attributes %i[home_placement email_addresses]
  permit_attributes %i[accept_terms password password_confirmation current_password time_zone language]
  permit_attributes %i[first_name middle_name last_name hide_last_name about show_feed is_public]
  permit_attributes %i[reactions_email news_email decisions_email memberships_email created_email has_analytics]
  permit_attributes %i[url], has_properties: {url: false}
  permit_attributes %i[email redirect_url], new_record: true
  permit_attributes %i[destroy_strategy], grant_sets: %i[staff]

  def permitted_tabs
    tabs = []
    tabs.concat %i[general profile authentication]
    tabs.append :emails
    tabs.concat %i[notifications privacy advanced]
    tabs.append :delete
    tabs
  end

  def show?
    (record.is_public? || !user.guest?) || super
  end

  def create?
    true
  end

  def follow_items?
    true
  end

  def max_allowed_pages
    if staff?
      Float::INFINITY
    elsif user
      1
    else
      0
    end
  end

  def max_pages_reached?
    user.page_count >= max_allowed_pages
  end

  def update?
    current_user? || super
  end
  alias language? update?

  def setup?
    current_user? && !user.setup_finished?
  end

  def destroy?
    if record.profile.grants.administrator.count.positive?
      forbid_with_message(I18n.t('users_cancel_super_admin'))
    else
      current_user? || staff?
    end
  end

  def current_user?
    record.id == user.id
  end

  private

  def home_placement_attributes
    HomePlacementPolicy.new(context, record.home_placement || HomePlacement.new(placeable: record)).permitted_attributes
  end
end
