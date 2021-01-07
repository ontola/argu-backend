# frozen_string_literal: true

class GuestUser < User
  include NoPersistence
  attr_writer :id

  def access_tokens
    []
  end

  def build_shortname_if; end

  def default_profile_photo
    @default_profile_photo ||= User.community.default_profile_photo
  end

  def display_name
    I18n.t('users.guest')
  end

  def follow_for(_followable)
    nil
  end

  def id
    @id ||= SecureRandom.hex
  end

  def iri_opts
    {id: id}
  end

  def guest?
    true
  end

  def initialize(attributes = {})
    attributes ||= {}
    attributes[:time_zone] ||= 'Amsterdam'
    super
  end

  def managed_profile_ids
    []
  end

  def otp_secret; end

  def profile
    @profile ||= GuestProfile.find(COMMUNITY_ID)
    @profile.profileable = self
    @profile
  end

  def self.iri
    NS::ONTOLA[:GuestUser]
  end
end
