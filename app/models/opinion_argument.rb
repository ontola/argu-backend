class OpinionArgument < ActiveRecord::Base
  belongs_to :argument
  belongs_to :opinion
  before_create :set_original_argument_is

  def set_original_argument_is
    self.original_argument_id = argument_id
  end
end
