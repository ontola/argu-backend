# frozen_string_literal: true

class Phase < Edge
  enhance Attachable
  enhance BlogPostable
  enhance BudgetShoppable
  enhance Commentable
  enhance Contactable
  enhance Convertible
  enhance CoverPhotoable
  enhance Exportable
  enhance Feedable
  enhance Inviteable
  enhance Moveable
  enhance Placeable
  enhance Statable
  enhance Surveyable
  enhance Questionable
  enhance Motionable
  enhance Widgetable
  enhance Orderable
  include Edgeable::Content

  counter_cache true
  parentable :project

  property :time, :string, NS.argu[:time]

  validates :display_name, presence: true, length: {minimum: 4, maximum: 75}
  validates :description, length: {maximum: MAXIMUM_DESCRIPTION_LENGTH}
end
