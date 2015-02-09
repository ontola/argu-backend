module MailerHelper
  def profile_to_recipient_option(profile)
    Hash[profile.email, profile.attributes.slice('id', 'name')]
  end

  def different_creator(a, b)
    a.creator.id != b.creator.id
  end
end