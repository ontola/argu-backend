# frozen_string_literal: true
class ArgumentSerializer < BaseCommentSerializer
  attributes :display_name, :content, :pro

  has_many :comment_threads do
    meta do
      href = object.class.try(:context_id_factory)&.call(object)
      {
        '@type': 'http://schema.org/relation',
        '@id': "#{href}/c"
      }
    end
  end

  def votes_neutral_count; end

  def votes_con_count; end
end
