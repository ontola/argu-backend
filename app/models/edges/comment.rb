# frozen_string_literal: true

class Comment < Edge
  enhance ActivePublishable
  enhance Convertible

  include Edgeable::Content

  property :parent_comment_id, :linked_edge_id, NS.argu[:inReplyTo], association_class: 'Comment'
  property :pdf_position_x, :integer, NS.argu[:pdfPositionX]
  property :pdf_position_y, :integer, NS.argu[:pdfPositionY]
  property :pdf_page, :integer, NS.argu[:pdfPage]

  has_many :comments, primary_key_property: :parent_comment_id, class_name: 'Comment', dependent: false
  has_many :active_comments,
           -> { active },
           primary_key_property: :parent_comment_id,
           class_name: 'Comment',
           dependent: false,
           inverse_of: :parent_comment
  belongs_to :commentable, polymorphic: true

  counter_cache comments: {}, threads: {parent_comment_id: nil}
  with_collection :comments, counter_cache_column: nil
  paginates_per 10
  parentable :pro_argument, :con_argument, :blog_post, :motion, :question, :topics,
             :intervention, :intervention_type, :measure, :linked_records
  filterable NS.argu[:pdfPage] => {values: []}

  validates :description, presence: true, allow_nil: false, length: {in: 4..5000}
  validates :creator, presence: true

  attr_accessor :is_processed

  def deleted?
    body.blank? || body == '[DELETED]'
  end

  def parent_collections(user_context)
    return super if parent_comment.blank?

    [parent_comment.comment_collection(user_context: user_context)]
  end

  def added_delta
    super + [
      [parent.iri, NS.argu[:topComment], iri, NS.ontola[:replace]]
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
      update_attribute(:body, '') # rubocop:disable Rails/SkipsModelValidations
    end
  end

  class << self
    def attributes_for_new(opts)
      return super unless opts[:parent].is_a?(Comment)

      attrs = super
      attrs[:parent] = opts[:parent].parent
      attrs[:parent_comment_id] = opts[:parent].uuid
      attrs
    end

    def route_key
      :c
    end
  end
end
