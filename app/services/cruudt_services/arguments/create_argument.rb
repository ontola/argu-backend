
class CreateArgument < PublishedCreateService
  include Wisper::Publisher

  def initialize(argument, attributes = {}, options = {})
    @argument = argument
    super
  end

  def resource
    @argument
  end

  private

  def after_save
    super
    if @options[:auto_vote]
      resource
        .votes
        .create(voter: resource.creator,
                publisher: resource.creator.profileable,
                forum: resource.forum,
                for: :pro)
    end
  end
end
