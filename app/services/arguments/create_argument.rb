
class CreateArgument < CreateService
  include Wisper::Publisher

  def initialize(profile, attributes = {}, options = {})
    @argument = profile.arguments.new
    super
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
end
