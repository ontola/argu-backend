
class CreateArgument < CreateService
  include Wisper::Publisher

  def initialize(argument, attributes = {}, options = {})
    @argument = argument
    super
    if options[:auto_vote]
      @argument
          .votes
          .build(voter: @argument.creator,
                 forum: @argument.forum,
                 for: :pro)
    end
  end

  def resource
    @argument
  end
end
