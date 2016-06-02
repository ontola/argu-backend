
class CreateAnnouncement < CreateService
  include Wisper::Publisher

  def initialize(profile, attributes = {})
    @announcement = Announcement.new(attributes)
    super
  end

  def resource
    @announcement
  end
end
