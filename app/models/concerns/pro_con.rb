# frozen_string_literal: true
module ProCon
  extend ActiveSupport::Concern

  VOTE_OPTIONS = [:pro].freeze

  included do
    include Trashable, Parentable, HasLinks, PublicActivity::Common, Commentable

    has_many :votes, as: :voteable, dependent: :destroy
    belongs_to :creator, class_name: 'Profile'
    belongs_to :forum

    before_save :cap_title

    validates :content, presence: false, length: {maximum: 5000}
    validates :title, presence: true, length: {minimum: 5, maximum: 75}
    validates :creator, presence: true
    auto_strip_attributes :title, squish: true
    auto_strip_attributes :content

    parentable :motion, :linked_record

    scope :pro, -> { where(pro: true) }
    scope :con, -> { where(pro: false) }

    # Simple method to verify that a model uses {ProCon}
    def is_pro_con?
      true
    end
  end

  def cap_title
    title[0] = title[0].upcase
    title
  end

  def display_name
    title
  end

  # To facilitate the group_by command
  def key
    pro ? :pro : :con
  end

  # noinspection RubySuperCallWithoutSuperclassInspection
  def pro=(value)
    value = false if value.to_s == 'con'
    super value.to_s == 'pro' || value
  end

  def root_comments
    comment_threads.untrashed.where(parent_id: nil)
  end

  module ClassMethods
    def ordered(coll = [], page = {})
      HashWithIndifferentAccess.new(
        pro: {
          collection: coll.pro.page(page[:pro] || 1) || [],
          page_param: :page_arg_pro
        },
        con: {
          collection: coll.con.page(page[:con] || 1) || [],
          page_param: :page_arg_con
        }
      )
    end
  end

  module ActiveRecordExtension
    def self.included(base)
      base.class_eval do
        def self.is_pro_con?
          false
        end
      end
    end

    # Useful to test whether a model uses {ProCon}
    def is_pro_con?
      false
    end
  end
  ActiveRecord::Base.send(:include, ActiveRecordExtension)
end
