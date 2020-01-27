# frozen_string_literal: true

class Project < Discussion
  enhance Phaseable
  include Edgeable::Content
  after_create :create_default_phases

  with_collection :phases

  property :current_phase_id, :linked_edge_id, NS::ARGU[:currentPhase], default: nil

  belongs_to :current_phase, foreign_key_property: :current_phase_id, class_name: 'Phase', dependent: false

  validates :display_name, presence: true, length: {minimum: 4, maximum: 75}
  validates :description, length: {maximum: MAXIMUM_DESCRIPTION_LENGTH}

  private

  def create_default_phases # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    service_options = {creator: creator, publisher: publisher}
    pa_id = PermittedAction.find_by!(title: 'phase_show').id
    description_placeholder = I18n.t('projects.phase_template.description_placeholder')
    identify = phases.create!(
      service_options.merge(
        order: 1,
        description: description_placeholder,
        name: I18n.t('projects.phase_template.survey.name'),
        is_published: true
      )
    )

    survey = CreateEdge.new(
      identify,
      attributes: {
        owner_type: 'Survey',
        name: I18n.t('surveys.type'),
        description: description_placeholder,
        argu_publication_attributes: {draft: true}
      },
      options: service_options
    ).commit
    Widget.custom.create!(owner: identify, size: 3, resource_iri: [[survey.iri, nil]], permitted_action_id: pa_id)

    cocreate = phases.create!(
      service_options.merge(
        order: 2,
        description: description_placeholder,
        name: I18n.t('projects.phase_template.question.name'),
        is_published: true
      )
    )
    question = CreateEdge.new(
      cocreate,
      attributes: {
        owner_type: 'Question',
        name: I18n.t('questions.type'),
        description: description_placeholder,
        argu_publication_attributes: {draft: true}
      },
      options: service_options
    ).commit

    Widget.custom.create!(owner: cocreate, size: 3, resource_iri: [[question.iri, nil]], permitted_action_id: pa_id)

    decide = phases.create!(
      service_options.merge(
        order: 3,
        description: description_placeholder,
        name: I18n.t('projects.phase_template.blog_post.name'),
        is_published: true
      )
    )
    blog_post = CreateEdge.new(
      cocreate,
      attributes: {
        owner_type: 'BlogPost',
        name: I18n.t('blog_posts.type'),
        description: description_placeholder,
        argu_publication_attributes: {draft: true}
      },
      options: service_options
    ).commit
    Widget.custom.create!(owner: decide, size: 3, resource_iri: [[blog_post.iri, nil]], permitted_action_id: pa_id)

    update!(current_phase: identify)
  end
end
