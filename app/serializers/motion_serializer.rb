class MotionSerializer < BaseSerializer
  include Loggable::Serlializer
  include MotionsHelper

  attributes :distribution
  attribute :display_name, key: :title
  attribute :content, key: :text

  def distribution
    motion_vote_counts(object)
  end
end
