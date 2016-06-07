class PublishedCreateService < CreateService
  # @note Call super when overriding.
  def initialize(resource, attributes = {}, options = {})
    attributes[:publisher] = options[:publisher]
    attributes[:creator] = options[:creator]
    super
  end

  private

  def after_save
    resource.publisher.follow(resource.edge)
    resource.edge.ancestors.where(owner_type: %w(Motion Question Project)).each do |ancestor|
      current_follow_type = resource.publisher.following_type(ancestor)
      if Follow.follow_types[:news] > Follow.follow_types[current_follow_type]
        resource.publisher.follow(ancestor, :news)
      end
    end
  end
end
