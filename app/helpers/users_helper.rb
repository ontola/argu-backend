module UsersHelper
  def forum_from_r_action(user)
    if user.r.present?
      url_options, controller = r_to_url_options(user.r)
      if current_resource_is_nested?(url_options)
        resource_tenant(url_options, url_options)
      else
        controller_inst = controller.new
        controller_inst.forum_for(url_options) if controller.present? && controller_inst.respond_to?(:forum_for)
      end
    end
  end

  def identity_token(identity)
    sign_payload(identity: identity.id)
  end

  def login_providers_left(user)
    User.omniauth_providers.dup.delete_if { |p| user.identities.pluck(:provider).include?(p.to_s) }
  end

  def options_for_reactions_email
    User.reactions_emails.keys.map { |n| [I18n.t("users.reactions_email.#{n}"), n] }
  end

  def options_for_news_email
    User.news_emails.keys.map { |n| [I18n.t("users.news_email.#{n}"), n] }
  end

  def options_for_decisions_email
    User.decisions_emails.keys.map { |n| [I18n.t("users.decisions_email.#{n}"), n] }
  end

  def options_for_memberships_email
    User.memberships_emails.keys.map { |n| [I18n.t("users.memberships_email.#{n}"), n] }
  end

  def options_for_created_email
    User.created_emails.keys.map { |n| [I18n.t("users.created_email.#{n}"), n] }
  end

  # Assigns certain memberships based on
  #   either an 'r' action
  #   or preferred_forum
  #   if the user hasn't got any memberships yet
  def setup_memberships(user)
    # changed? so we can safely write back to the DB
    if user.valid? && user.persisted? && !user.changed?
      if user.profile.grants.member.blank?
        begin
          forum = forum_from_r_action(user) || preferred_forum(user.profile)
          if forum.present? && policy(forum).join?
            CreateGroupMembership
              .new(forum.members_group.edge,
                   attributes: {member: user.profile},
                   options: {creator: user.profile, publisher: user})
              .commit
          end
        rescue ActiveRecord::RecordNotFound => e
          Bugsnag.notify(e)
        end
      end
    end
  end
end
