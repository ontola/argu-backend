# frozen_string_literal: true

class AnonymousUser < User
  def display_name
    I18n.t('users.anonymous')
  end

  def profile
    @profile ||= Profile.anonymous
    @profile.profileable = self
    @profile
  end

  def self.iri
    [NS.ontola[:AnonymousUser], NS.schema.Person]
  end

  private

  def anonymous_iri?
    false
  end

  def iri_template_name
    :users_iri
  end
end
