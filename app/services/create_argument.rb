
class CreateArgument < ApplicationService
  include Wisper::Publisher

  def initialize(profile, attributes = {}, options = {})
    @argument = profile.arguments.new(attributes)
    if attributes[:publisher].blank? && profile.profileable.is_a?(User)
      @argument.publisher = profile.profileable
    end
    if options[:auto_vote] == true && profile.profileable.is_a?(User)
      @argument
          .votes
          .build(voter: profile,
                 forum: @argument.forum,
                 for: :pro)
    end
  end

  def resource
    @argument
  end

  def commit
    if @argument.valid? && @argument.save
      @argument.publisher.follow(@argument)
      publish(:create_argument_successful, @argument)
    else
      publish(:create_argument_failed, @argument)
    end
  end

end
