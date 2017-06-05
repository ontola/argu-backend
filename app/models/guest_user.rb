# frozen_string_literal: true
class GuestUser < User
  include NoPersistence
  attr_accessor :cookies, :headers, :id, :session

  contextualize_as_type 'schema:Person'
  contextualize_with_id { |r| "https://#{Rails.application.config.host_name}/sessions/#{r.id}" }
  contextualize :display_name, as: 'schema:name'

  def access_tokens
    []
  end

  def build_shortname_if; end

  def display_name
    I18n.t('users.guest')
  end

  def id
    @id ||= session.id
  end

  def language
    @language ||= attributes[:language] ||= cookies['locale'] || language_from_header || I18n.locale.to_s
  end

  def favorite_forum_ids
    []
  end

  def guest?
    true
  end

  def has_favorite?(_edge)
    false
  end

  def initialize(attributes = nil)
    @cookies ||= {}
    @headers ||= {}
    attributes[:time_zone] ||= 'Amsterdam'
    super
  end

  def managed_profile_ids
    []
  end

  def profile
    @profile ||= GuestProfile.find(0)
    @profile.profileable = self
    @profile
  end

  private

  def language_from_header
    HttpAcceptLanguage::Parser
      .new(headers['HTTP_ACCEPT_LANGUAGE'])
      .compatible_language_from(I18n.available_locales)
  end
end
