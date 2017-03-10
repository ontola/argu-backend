# frozen_string_literal: true
class GuestUser < User
  include Ldable
  attr_accessor :cookies, :headers, :id, :session
  delegate :member_of?, to: :profile

  contextualize_as_type 'schema:Person'
  contextualize_with_id { |r| "https://#{Rails.application.config.host}/sessions/#{r.id}" }
  contextualize :display_name, as: 'schema:name'

  def access_tokens
    []
  end

  def display_name
    I18n.t('users.guest')
  end

  def id
    @id ||= session.id
  end

  def language
    @language ||=
      cookies['locale'] ||
      HttpAcceptLanguage::Parser.new(headers['HTTP_ACCEPT_LANGUAGE']).compatible_language_from(I18n.available_locales)
  end

  def favorite_forum_ids
    []
  end

  def guest?
    true
  end

  def profile
    @profile ||= Profile.new(profileable: self)
  end

  def time_zone
    'Amsterdam'
  end
end
