# frozen_string_literal: true

class Comment < Edge
  enhance ActivePublishable
  enhance Convertible

  include Edgeable::Content

  property :parent_comment_id, :linked_edge_id, NS::ARGU[:inReplyTo], default: nil
  property :pdf_position_x, :integer, NS::ARGU[:pdfPositionX], default: nil
  property :pdf_position_y, :integer, NS::ARGU[:pdfPositionY], default: nil
  property :pdf_page, :integer, NS::ARGU[:pdfPage], default: nil

  has_one :vote, primary_key_property: :comment_id, dependent: false
  belongs_to :parent_comment, foreign_key_property: :parent_comment_id, class_name: 'Comment', dependent: false
  has_many :comments, primary_key_property: :parent_comment_id, class_name: 'Comment', dependent: false
  has_many :active_comments,
           -> { active },
           primary_key_property: :parent_comment_id,
           class_name: 'Comment',
           dependent: false,
           inverse_of: :parent_comment
  belongs_to :commentable, polymorphic: true

  after_commit :set_vote, on: :create
  after_trash :unlink_vote

  counter_cache comments: {}, threads: {parent_comment_id: nil}
  with_collection :comments, counter_cache_column: nil
  paginates_per 10
  parentable :pro_argument, :con_argument, :blog_post, :motion, :question, :topics,
             :intervention, :intervention_type, :measure, :linked_records
  filterable NS::ARGU[:pdfPage] => {values: []}

  validates :description, presence: true, allow_nil: false, length: {in: 4..5000}
  validates :creator, presence: true

  attr_accessor :is_processed, :vote_id

  def deleted?
    body.blank? || body == '[DELETED]'
  end

  def parent_collections(user_context)
    return super if parent_comment.blank?

    [parent_comment.comment_collection(user_context: user_context)]
  end

  def added_delta
    super + [
      [parent.iri, NS::ARGU[:topComment], iri, NS::ONTOLA[:replace]]
    ]
  end

  def shallow_wipe
    if is_trashed?
      self.body = '[DELETED]'
      self.creator = nil
      self.is_processed = true
    end
    comments.each(&:shallow_wipe) if comments.present?
  end

  # Comments can't be deleted since all comments below would be hidden as well
  def wipe
    Comment.transaction do
      trash unless is_trashed?
      Comment.anonymize(Comment.where(id: id))
      unlink_vote
      update_attribute(:body, '') # rubocop:disable Rails/SkipsModelValidations
    end
  end

  private

  def set_vote
    return if vote_id.nil?

    vote = Vote.where_with_redis(creator: creator, uuid: vote_id, root_id: root_id).first ||
      raise(ActiveRecord::RecordNotFound)
    vote.update!(comment_id: uuid)
  end

  def unlink_vote
    vote&.update(comment_id: nil)
  end

  class << self
    def includes_for_serializer
      super.merge(comments: {}, vote: {})
    end

    def show_includes
      super + [
        comment_collection: inc_shallow_collection
      ]
    end
  end
end
