
class CreateGroupResponse < CreateService
  include Wisper::Publisher

  def initialize(profile, attributes = {}, options = {})
    motion, group, forum, creator, publisher, side = attributes.values_at(*%i(motion group forum creator publisher side))
    @group_response = motion
                        .group_responses
                        .new group: group,
                             forum: forum,
                             creator: creator,
                             publisher: publisher,
                             side: side
    super
    if attributes[:publisher].blank? && creator.profileable.is_a?(User)
      @group_response.publisher = creator.profileable
    end
  end

  def resource
    @group_response
  end
end
