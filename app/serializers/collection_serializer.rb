# frozen_string_literal: true
class CollectionSerializer < BaseSerializer
  attributes :member, :title, :group_by
  belongs_to :parent
  # has_many :member

  def member
    object.member.map do |i|
      h = i.respond_to?(:pro) ? {pro: i.pro} : {}
      h.merge(
        '@context': {
          pro: 'schema:option'
        },
        '@id': i.class.context_id_factory.call(i)
      )
    end
  end
end
