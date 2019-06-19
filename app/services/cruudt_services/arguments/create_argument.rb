# frozen_string_literal: true

class CreateArgument < PublishedCreateService
  private

  def after_save
    super
    resource.upvote(resource.creator.profileable, resource.creator) if @options[:auto_vote]
  end

  def assign_attributes # rubocop:disable Metrics/AbcSize
    super
    klass = resource.pro ? ProArgument : ConArgument
    became = resource.becomes(klass)
    became.owner_type = klass.sti_name
    became.properties = resource.properties
    became.parent = resource.parent
    became.argu_publication = resource.argu_publication
    became.instance_variable_set(:@mutations_from_database, resource.send(:mutations_from_database))
    @edge = became
  end

  def object_attributes=(obj)
    obj.creator ||= resource.creator
    obj.publisher ||= resource.publisher
  end
end
