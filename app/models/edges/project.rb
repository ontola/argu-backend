# frozen_string_literal: true

class Project < Discussion
  enhance Phaseable
  include Edgeable::Content
  after_create :create_default_phases

  with_collection :phases

  property :current_phase_id, :linked_edge_id, NS.argu[:currentPhase], association_class: 'Phase'

  validates :display_name, presence: true, length: {minimum: 4, maximum: 75}
  validates :description, length: {maximum: MAXIMUM_DESCRIPTION_LENGTH}

  private

  def create_default_phases # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    description_placeholder = I18n.t('projects.phase_template.description_placeholder')

    identify = phases.create!(
      active_branch: active_branch,
      creator: creator,
      description: description_placeholder,
      is_published: true,
      name: I18n.t('projects.phase_template.survey.name'),
      position: 1,
      publisher: publisher,
      resource_type: :survey
    )
    phases.create!(
      active_branch: active_branch,
      creator: creator,
      description: description_placeholder,
      is_published: true,
      name: I18n.t('projects.phase_template.question.name'),
      position: 2,
      publisher: publisher,
      resource_type: :question
    )
    phases.create!(
      active_branch: active_branch,
      creator: creator,
      description: description_placeholder,
      is_published: true,
      name: I18n.t('projects.phase_template.blog_post.name'),
      position: 3,
      publisher: publisher,
      resource_type: :blog_post
    )

    update!(current_phase: identify)
  end
end
