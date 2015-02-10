class Activity < PublicActivity::Activity

  scope :since, ->(from_time = nil) { where('created_at < :from_time', {from_time: from_time}) if from_time.present? }

  def collect_recipients(type = :directly)
    profiles = Set.new
    if type == :directly
      profiles.merge trackable.followers_by_type('Profile').joins('LEFT OUTER JOIN users ON users.profile_id = profiles.id').where(users: {follows_emails: User.memberships_emails[:direct_follows_email]})
      profiles.merge trackable.collect_recipient(type)
    end
    profiles
  end
end
