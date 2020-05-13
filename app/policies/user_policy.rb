# frozen_string_literal: true

class UserPolicy < RestrictivePolicy
  class Scope < Scope
    def resolve
      scope
    end
  end
  include ChildOperations

  def permitted_attribute_names(password = false) # rubocop:disable Metrics/MethodLength
    attrs = super()
    attrs.concat %i[password password_confirmation primary_email current_password]
    attrs.append(home_placement_attributes: home_placement_attributes)
    attrs.append(email_addresses_attributes: %i[email _destroy id])
    attrs.append(:url, shortname_attributes: %i[shortname]) if record.url.nil?
    attrs.concat %i[first_name middle_name last_name hide_last_name about show_feed is_public]
    attrs.concat(
      %i[reactions_email news_email decisions_email memberships_email
         created_email has_analytics has_analytics time_zone language
         birthday]
    )
    attrs.concat %i[current_password password password_confirmation] if password
    attrs
  end

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
  alias wrong_email? update?

  def setup?
    current_user? && user.url.blank?
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
