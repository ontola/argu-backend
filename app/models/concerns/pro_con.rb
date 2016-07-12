# frozen_string_literal: true
module ProCon
  extend ActiveSupport::Concern

  VOTE_OPTIONS = [:pro].freeze

  included do
    include ArguBase, Trashable, Parentable, HasLinks, PublicActivity::Common

    belongs_to :motion, touch: true
    has_many :votes, as: :voteable, dependent: :destroy, inverse_of: :voteable
    has_many :activities,
             -> { where("key ~ '*.!happened'") },
             as: :trackable
    belongs_to :creator, class_name: 'Profile'
    belongs_to :forum

    before_save :cap_title
    after_create :update_vote_counters

    validates :content, presence: true, length: {minimum: 5, maximum: 5000}
    validates :title, presence: true, length: {minimum: 5, maximum: 75}
    validates :creator, :motion, :forum, presence: true
    auto_strip_attributes :title, squish: true
    auto_strip_attributes :content

    acts_as_commentable
    parentable :motion, :forum

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
    comment_threads.where(is_trashed: false, parent_id: nil)
  end

  def update_vote_counters
    vote_counts = votes.group('"for"').count
    update votes_pro_count: vote_counts[Vote.fors[:pro]] || 0,
           votes_con_count: vote_counts[Vote.fors[:con]] || 0,
           votes_abstain_count: vote_counts[Vote.fors[:abstain]] || 0
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
