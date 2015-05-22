module UsersHelper
  def identity_token(identity)
    encrypt_payload({
                        identity: identity.id
                    })
  end

  def login_providers_left(user)
    User.omniauth_providers.delete_if { |p| user.identities.pluck(:provider).include?(p.to_s) }
  end

  def options_for_follows_email
    User.follows_emails.keys.map { |n| [I18n.t("users.follows_email.#{n}"), n] }
  end

  def options_for_memberships_email
    User.memberships_emails.keys.map { |n| [I18n.t("users.memberships_email.#{n}"), n] }
  end

  def options_for_created_email
    User.created_emails.keys.map { |n| [I18n.t("users.created_email.#{n}"), n] }
  end

  # Set user_cap to 0 to close the platform
  def platform_open?
    cap = Setting.get('user_cap').try(:to_i)
    cap.present? and cap > 0 || cap == -1
  end

  # Set user_cap to -1 to disable the cap
  def within_user_cap?
    cap = Setting.get('user_cap').try(:to_i)
    cap.present? and cap == -1 || (cap > 0 && Shortname.where(owner_type: 'User').count < cap)
  end
end
