
class CreateGroupResponse < CreateService
  include Wisper::Publisher

  def initialize(profile, attributes = {}, options = {})
    motion, group, forum, profile, publisher, side = attributes.values_at(*%i(motion group forum profile publisher side))
    @group_response = motion
                        .group_responses
                        .new group: group,
                             forum: forum,
                             profile: profile,
                             publisher: publisher,
                             side: side
    super
    if attributes[:publisher].blank? && profile.profileable.is_a?(User)
      @group_response.publisher = profile.profileable
    end
  end

  def resource
    @group_response
  end
end
