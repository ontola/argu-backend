# frozen_string_literal: true

class CreateAnnouncement < CreateService
  def initialize(profile, attributes: {}, options: {})
    @resource = Announcement.new(attributes)
    super
  end
end
