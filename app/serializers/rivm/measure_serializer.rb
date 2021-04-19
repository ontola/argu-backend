# frozen_string_literal: true

class MeasureSerializer < ContentEdgeSerializer
  attribute :second_opinion, predicate: NS::RIVM[:secondOpinion]
  attribute :second_opinion_by, predicate: NS::RIVM[:secondOpinionBy]
  attribute :attachment_published_at, predicate: NS::RIVM[:attachmentPublicationDate]
  attribute :measure_owner, predicate: NS::RIVM[:measureOwner]
  attribute :contact_info, predicate: NS::RIVM[:contactInfo]
  attribute :more_info, predicate: NS::RIVM[:moreInfo]
  enum :comments_allowed, predicate: NS::RIVM[:commentsAllowed]
  has_many :phases, predicate: NS::RIVM[:phases]
  has_many :categories, predicate: NS::RIVM[:categories]
end
