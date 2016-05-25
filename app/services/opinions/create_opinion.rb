# Service for the creation of opinions
class CreateOpinion < CreateService
  include Wisper::Publisher

  def initialize(opinion, attributes = {}, options = {})
    @opinion = opinion
    opinion_arguments_ids = attributes.delete(:opinion_arguments_ids)
    opinion_arguments_ids.each { |id| @opinion.opinion_arguments.build(argument_id: id) }
    super
  end

  def resource
    @opinion
  end
end
