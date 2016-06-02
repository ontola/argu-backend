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
  end
end
