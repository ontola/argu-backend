# frozen_string_literal: true
class BaseCommentSerializer < BaseEdgeSerializer
  attributes :votes_pro_count, :votes_con_count, :votes_neutral_count

  def votes_pro_count
    object.children_count(:votes_pro)
  end

  def votes_neutral_count
    object.children_count(:votes_neutral)
  end

  def votes_con_count
    object.children_count(:votes_con)
  end
end
