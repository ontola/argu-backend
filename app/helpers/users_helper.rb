# frozen_string_literal: true

module UsersHelper
  include IRIHelper

  def forum_from_r_action(user)
    return if user.r.nil?
    resource = resource_from_iri(user.r)
    return if resource.nil? || resource.is_a?(Page) || !resource.is_fertile?
    return resource if resource.is_a?(Forum)
    resource.parent_model(:forum)
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

  def r_param
    r = (params[:user]&.permit(:r) || params.permit(:r)).try(:[], :r)
    r if valid_redirect?(r)
  end

  def redirect_with_r(user)
    if user.r.present?
      r = URI.decode(user.r)
      user.update r: ''
    end
    redirect_to r.presence || root_path
  end

  # Assigns certain favorites based on
  #   either an 'r' action
  #   or preferred_forum
  #   if the user hasn't got any favorites yet
  def setup_favorites(user)
    # changed? so we can safely write back to the DB
    return unless user.valid? && user.persisted?
    return if user.favorites.present?
    begin
      forum = forum_from_r_action(user) || preferred_forum(user.profile)
      Favorite.create!(user: user, edge: forum.edge) if forum.present?
    rescue ActiveRecord::RecordNotFound => e
      Bugsnag.notify(e)
    end
  end
end
