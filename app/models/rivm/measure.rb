# frozen_string_literal: true

class Measure < Edge
  include Edgeable::Content
  enhance Attachable
  enhance Commentable
  enhance Feedable
  enhance Statable
  enhance GrantResettable
  enhance ActivePublishable
  enhance Placeable
  enhance RootGrantable

  parentable :page

  validates :description, length: {maximum: MAXIMUM_DESCRIPTION_LENGTH}
  validates :display_name, presence: true, length: {maximum: 110}
  validates :comments_allowed, presence: true
  before_save :sync_comments_allowed

  counter_cache true
  placeable :custom

  property :comments_allowed, :integer, NS::RIVM[:commentsAllowed], enum: {
    comments_are_allowed: 1,
    comments_not_allowed: 2
  }
  term_property :phase_ids, NS::RIVM[:phases], array: true, association: :phases
  term_property :category_ids, NS::RIVM[:categories], array: true, association: :categories
  property :second_opinion, :boolean, NS::RIVM[:secondOpinion]
  property :second_opinion_by, :string, NS::RIVM[:secondOpinionBy]
  property :attachment_published_at, :datetime, NS::RIVM[:attachmentPublicationDate]
  property :measure_owner, :string, NS::RIVM[:measureOwner]
  property :contact_info, :string, NS::RIVM[:contactInfo]
  property :more_info, :string, NS::RIVM[:moreInfo]
  filterable(
    NS::RIVM[:categories] => {
      filter: lambda do |scope, values|
        scope.where(category_ids: values.map { |value| LinkedRails.iri_mapper.resource_from_iri(value).uuid })
      end,
      values_in: -> { Vocabulary.new(url: :categorieen).term_collection(page_size: 999).iri }
    }
  )

  private

  def sync_comments_allowed
    current_reset = grant_resets.find_by(action: 'create', resource_type: 'Comment')
    if comments_are_allowed?
      self.grant_resets_attributes = [id: current_reset.id, _destroy: true] if current_reset
    else
      self.grant_resets_attributes = [action: 'create', resource_type: 'Comment'] unless current_reset
    end
  end

  class << self
    def default_public_grant
      :participator
    end

    def iri_namespace
      NS::RIVM
    end
  end
end
