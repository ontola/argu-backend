# frozen_string_literal: true

class CreateArgument < PublishedCreateService
  private

  def after_save
    super
    resource.upvote(resource.creator.profileable, resource.creator) if @options[:auto_vote]
  end

  def assign_attributes
    super
    klass = resource.pro ? ProArgument : ConArgument
    became = resource.becomes(klass)
    became.owner_type = klass.sti_name
    became.properties = resource.properties
    became.parent = resource.parent
    became.instance_variable_set(:@mutations_from_database, resource.send(:mutations_from_database))
    @edge = became
  end
end
