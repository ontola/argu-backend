
class CreateAnnouncement < ApplicationService
  include Wisper::Publisher

  def initialize(profile, attributes = {})
    @announcement = Announcement.new(attributes)
  end

  def resource
    @announcement
  end

  def commit
    if @announcement.valid? && @announcement.save
      publish(:create_announcement_successful, @announcement)
    else
      publish(:create_announcement_failed, @announcement)
    end
  end

end
