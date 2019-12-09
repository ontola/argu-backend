# frozen_string_literal: true

class GuestUser < User
  include NoPersistence
  attr_accessor :id, :session

  def access_tokens
    []
  end

  def build_shortname_if; end

  def display_name
    I18n.t('users.guest')
  end

  def follow_for(_followable)
    nil
  end

  def iri_opts
    {id: id}
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

  def initialize(attributes = {})
    attributes ||= {}
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

  def self.iri
    NS::ONTOLA[:GuestUser]
  end
end
