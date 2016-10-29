# frozen_string_literal: true

class ArgumentSerializer < BaseCommentSerializer
  attributes :display_name, :content, :pro
  # belongs_to :motion
  # has_one :creator

  def votes_neutral_count; end

  def votes_con_count; end
end
