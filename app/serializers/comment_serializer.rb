# frozen_string_literal: true
class CommentSerializer < BaseCommentSerializer
  attributes :body

  def votes_pro_count; end

  def votes_neutral_count; end

  def votes_con_count; end
end
