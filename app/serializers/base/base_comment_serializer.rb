# frozen_string_literal: true
class BaseCommentSerializer < BaseEdgeSerializer
  attributes :votes_pro_count, :votes_con_count, :votes_neutral_count
end
