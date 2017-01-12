# frozen_string_literal: true
module Argumentable
  extend ActiveSupport::Concern

  included do
    has_many :arguments, -> { argument_comments }, as: :argumentable
    has_many :top_arguments_con, (lambda do
      argument_comments
        .joins(:edge)
        .where(pro: false)
        .untrashed
        .order("edges.children_counts -> 'votes_pro' DESC")
        .limit(5)
    end), class_name: 'Argument'
    has_many :top_arguments_pro, (lambda do
      argument_comments
        .joins(:edge)
        .where(pro: true)
        .untrashed
        .order("edges.children_counts -> 'votes_pro' DESC")
        .limit(5)
    end), class_name: 'Argument'
    has_many :arguments_plain, class_name: 'Argument'

    def argument_collection(opts = {})
      Collection.new(
        {
          parent: self,
          association: :arguments,
          views: [
            Collection.new(filter: {option: :yes}, title: 'Arguments pro'),
            Collection.new(filter: {option: :no}, title: 'Arguments con')
          ]
        }.merge(opts)
      )
    end

    def invert_arguments
      false
    end

    def invert_arguments=(invert)
      return if invert == '0'
      Motion.transaction do
        arguments.each do |a|
          a.update_attributes pro: !a.pro
        end
      end
    end
  end

  module Serlializer
    extend ActiveSupport::Concern
    included do
      has_many :argument_collection do
        link(:self) do
          {
            href: "#{object.context_id}/arguments",
            meta: {
              '@type': 'argu:arguments'
            }
          }
        end
        meta do
          href = object.context_id
          {
            '@type': 'argu:collectionAssociation',
            '@id': "#{href}/arguments"
          }
        end
      end
    end
  end
end
