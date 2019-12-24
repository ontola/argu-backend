class AddDymanicThings < ActiveRecord::Migration[5.2]
  include UriTemplateHelper

  def down
    Thing.destroy_all
  end

  def up
    add_column :properties, :iri, :string
    add_column :properties, :language, :string
    PermittedAction.create_for_grant_sets('Thing', 'show', GrantSet.reserved)
    PermittedAction.create_for_grant_sets('Thing', 'create', GrantSet.reserved(only: %w[administrator staff]))
    PermittedAction.create_for_grant_sets('Thing', 'update', GrantSet.reserved(only: %w[administrator staff]))
    PermittedAction.create_for_grant_sets('Thing', 'trash', GrantSet.reserved(only: %w[administrator staff]))
    PermittedAction.create_for_grant_sets('Thing', 'destroy', GrantSet.reserved(only: %w[administrator staff]))

    return unless Apartment::Tenant.current == 'argu'

    ActsAsTenant.with_tenant(Page.argu) do
      thing = Thing.create!(
        publisher_id: User::SERVICE_ID,
        creator_id: Profile::SERVICE_ID,
        is_published: true,
        parent: Page.argu,
        url: :home,
        default_cover_photo_attributes: {
          remote_content_url: 'https://argu.co/nederland/media_objects/4195/content/content'
        }
      )
      Grant.create(group_id: Group::PUBLIC_ID, grant_set: GrantSet.spectator, edge: thing)
      Property.create!(edge: thing, predicate: RDF.type, iri: NS::ARGU[:ArguHome])

      # Identify
      step_identify = Thing.create!(publisher_id: User::SERVICE_ID, creator_id: Profile::SERVICE_ID, is_published: true, parent: thing)
      Property.create!(edge: step_identify, predicate: RDF.type, iri: NS::ARGU[:ProcessStep])
      Property.create!(edge: step_identify, predicate: NS::ARGU[:exampleClass], iri: NS::ARGU[:Survey])
      Property.create!(edge: step_identify, predicate: NS::ARGU[:icon], string: 'search')
      Property.create!(edge: step_identify, predicate: NS::SCHEMA[:color], string: '#475668')
      feature_survey = Thing.create!(publisher_id: User::SERVICE_ID, creator_id: Profile::SERVICE_ID, is_published: true, parent: thing)
      Property.create!(edge: feature_survey, predicate: NS::ARGU[:icon], string: 'pencil-square-o')
      feature_consulting = Thing.create!(publisher_id: User::SERVICE_ID, creator_id: Profile::SERVICE_ID, is_published: true, parent: thing)
      Property.create!(edge: feature_consulting, predicate: NS::ARGU[:icon], string: 'handshake-o')
      feature_challenge = Thing.create!(publisher_id: User::SERVICE_ID, creator_id: Profile::SERVICE_ID, is_published: true, parent: thing)
      Property.create!(edge: feature_challenge, predicate: NS::ARGU[:icon], string: 'puzzle-piece')

      Property.create!(edge: step_identify, predicate: NS::ARGU[:features], linked_edge: feature_survey)
      Property.create!(edge: step_identify, predicate: NS::ARGU[:features], linked_edge: feature_consulting)
      Property.create!(edge: step_identify, predicate: NS::ARGU[:features], linked_edge: feature_challenge)

      # Cocreate
      step_cocreate = Thing.create!(publisher_id: User::SERVICE_ID, creator_id: Profile::SERVICE_ID, is_published: true, parent: thing)
      Property.create!(edge: step_cocreate, predicate: RDF.type, iri: NS::ARGU[:ProcessStep])
      Property.create!(edge: step_cocreate, predicate: NS::ARGU[:exampleClass], iri: NS::ARGU[:Question])
      Property.create!(edge: step_cocreate, predicate: NS::ARGU[:icon], string: 'lightbulb-o')
      Property.create!(edge: step_cocreate, predicate: NS::SCHEMA[:color], string: '#3D80A7')
      feature_crowdsource_innovation = Thing.create!(publisher_id: User::SERVICE_ID, creator_id: Profile::SERVICE_ID, is_published: true, parent: thing)
      Property.create!(edge: feature_crowdsource_innovation, predicate: NS::ARGU[:icon], string: 'lightbulb-o')
      feature_reward = Thing.create!(publisher_id: User::SERVICE_ID, creator_id: Profile::SERVICE_ID, is_published: true, parent: thing)
      Property.create!(edge: feature_reward, predicate: NS::ARGU[:icon], string: 'rocket')
      feature_structure = Thing.create!(publisher_id: User::SERVICE_ID, creator_id: Profile::SERVICE_ID, is_published: true, parent: thing)
      Property.create!(edge: feature_structure, predicate: NS::ARGU[:icon], string: 'comments')

      Property.create!(edge: step_cocreate, predicate: NS::ARGU[:features], linked_edge: feature_crowdsource_innovation)
      Property.create!(edge: step_cocreate, predicate: NS::ARGU[:features], linked_edge: feature_reward)
      Property.create!(edge: step_cocreate, predicate: NS::ARGU[:features], linked_edge: feature_structure)

      # Decide
      step_decide = Thing.create!(publisher_id: User::SERVICE_ID, creator_id: Profile::SERVICE_ID, is_published: true, parent: thing)
      Property.create!(edge: step_decide, predicate: RDF.type, iri: NS::ARGU[:ProcessStep])
      Property.create!(edge: step_decide, predicate: NS::ARGU[:exampleClass], iri: NS::ARGU[:Motion])
      Property.create!(edge: step_decide, predicate: NS::ARGU[:icon], string: 'balance-scale')
      Property.create!(edge: step_decide, predicate: NS::SCHEMA[:color], string: '#60a9bf')
      feature_arguments = Thing.create!(publisher_id: User::SERVICE_ID, creator_id: Profile::SERVICE_ID, is_published: true, parent: thing)
      Property.create!(edge: feature_arguments, predicate: NS::ARGU[:icon], string: 'plus')
      Property.create!(edge: feature_arguments, predicate: NS::ARGU[:icon], string: 'minus')
      feature_voting = Thing.create!(publisher_id: User::SERVICE_ID, creator_id: Profile::SERVICE_ID, is_published: true, parent: thing)
      Property.create!(edge: feature_voting, predicate: NS::ARGU[:icon], string: 'thumbs-up')
      feature_decide = Thing.create!(publisher_id: User::SERVICE_ID, creator_id: Profile::SERVICE_ID, is_published: true, parent: thing)
      Property.create!(edge: feature_decide, predicate: NS::ARGU[:icon], string: 'gavel')

      Property.create!(edge: step_decide, predicate: NS::ARGU[:features], linked_edge: feature_arguments)
      Property.create!(edge: step_decide, predicate: NS::ARGU[:features], linked_edge: feature_voting)
      Property.create!(edge: step_decide, predicate: NS::ARGU[:features], linked_edge: feature_decide)

      # Cases
      case_hollandskroon = Thing.create!(publisher_id: User::SERVICE_ID, creator_id: Profile::SERVICE_ID, is_published: true, parent: thing)
      Property.create!(edge: case_hollandskroon, predicate: RDF.type, iri: NS::ARGU[:Case])
      Property.create!(edge: case_hollandskroon, predicate: NS::SCHEMA.image, iri: "#{Rails.application.config.frontend_url}/assets/cases/hollandskroon.jpg")
      Property.create!(edge: case_hollandskroon, predicate: NS::ARGU[:votesCount], integer: 3538)
      Property.create!(edge: case_hollandskroon, predicate: NS::ARGU[:reactionsCount], integer: 393)
      case_utrecht = Thing.create!(publisher_id: User::SERVICE_ID, creator_id: Profile::SERVICE_ID, is_published: true, parent: thing)
      Property.create!(edge: case_utrecht, predicate: RDF.type, iri: NS::ARGU[:Case])
      Property.create!(edge: case_utrecht, predicate: NS::SCHEMA.image, iri: "#{Rails.application.config.frontend_url}/assets/cases/utrecht.jpg")
      Property.create!(edge: case_utrecht, predicate: NS::ARGU[:votesCount], integer: 797)
      Property.create!(edge: case_utrecht, predicate: NS::ARGU[:reactionsCount], integer: 172)
      case_heerenveen = Thing.create!(publisher_id: User::SERVICE_ID, creator_id: Profile::SERVICE_ID, is_published: true, parent: thing)
      Property.create!(edge: case_heerenveen, predicate: RDF.type, iri: NS::ARGU[:Case])
      Property.create!(edge: case_heerenveen, predicate: NS::SCHEMA.image, iri: "#{Rails.application.config.frontend_url}/assets/cases/heerenveen.jpg")
      Property.create!(edge: case_heerenveen, predicate: NS::ARGU[:votesCount], integer: 180)
      Property.create!(edge: case_heerenveen, predicate: NS::ARGU[:reactionsCount], integer: 142)
      case_rochdale = Thing.create!(publisher_id: User::SERVICE_ID, creator_id: Profile::SERVICE_ID, is_published: true, parent: thing)
      Property.create!(edge: case_rochdale, predicate: RDF.type, iri: NS::ARGU[:Case])
      Property.create!(edge: case_rochdale, predicate: NS::SCHEMA.image, iri: "#{Rails.application.config.frontend_url}/assets/cases/rochdale.jpg")
      Property.create!(edge: case_rochdale, predicate: NS::ARGU[:votesCount], integer: 193)
      Property.create!(edge: case_rochdale, predicate: NS::ARGU[:reactionsCount], integer: 100)

      Property.create!(edge: thing, predicate: NS::ARGU[:processSteps], linked_edge: step_identify, order: 1)
      Property.create!(edge: thing, predicate: NS::ARGU[:processSteps], linked_edge: step_cocreate, order: 2)
      Property.create!(edge: thing, predicate: NS::ARGU[:processSteps], linked_edge: step_decide, order: 3)
      Property.create!(edge: thing, predicate: NS::ARGU[:cases], linked_edge: case_hollandskroon, order: 4)
      Property.create!(edge: thing, predicate: NS::ARGU[:cases], linked_edge: case_utrecht, order: 1)
      Property.create!(edge: thing, predicate: NS::ARGU[:cases], linked_edge: case_heerenveen, order: 2)
      Property.create!(edge: thing, predicate: NS::ARGU[:cases], linked_edge: case_rochdale, order: 3)
      [
        {id: 'amsterdam', alt: 'Gemeente Amsterdam'},
        {id: 'kvk', alt: 'Kamer van Koophandel'},
        {id: 'utrecht', alt: 'Gemeente Utrecht'},
        {id: 'alliander', alt: 'Alliander'},
        {id: 'tweedekamer', alt: 'Tweede Kamer'},
        {id: 'rochdale', alt: 'Rochdale'},
        {id: 'vng', alt: 'Vereniging van Nederlandse Gemeenten'},
        {id: 'alkmaar', alt: 'Gemeente Alkmaar'},
        {id: 'lelystad', alt: 'Gemeente Lelystad'},
        {id: 'heerenveen', alt: 'Gemeente Heerenveen'},
        {id: 'knwu', alt: 'Koninklijke Nederlandsche Wielren Unie'},
        {id: 'hollandskroon', alt: 'Gemeente Hollands Kroon'}
      ].each_with_index do |customer, index|
        resource = Thing.create!(publisher_id: User::SERVICE_ID, creator_id: Profile::SERVICE_ID, is_published: true, parent: thing)
        Property.create!(edge: resource, predicate: RDF.type, iri: NS::ARGU[:Customer])
        Property.create!(edge: thing, predicate: NS::ARGU[:customers], linked_edge: resource, order: index)
        Property.create!(edge: resource, predicate: NS::SCHEMA.name, string: customer[:alt])
        Property.create!(edge: resource, predicate: NS::SCHEMA.image, iri: "#{Rails.application.config.frontend_url}/assets/customers/#{customer[:id]}.jpg")
      end

      features = %w[voting invite opinions reports locations notifications manage attachments deadlines data branding blogging]
      feature = {}
      features.each_with_index do |name, index|
        feature[name] = Thing.create!(publisher_id: User::SERVICE_ID, creator_id: Profile::SERVICE_ID, is_published: true, parent: thing)
        Property.create!(edge: thing, predicate: NS::ARGU[:features], linked_edge: feature[name], order: index)
        Property.create!(edge: feature[name], predicate: RDF.type, iri: NS::ARGU[:Feature])
        Property.create!(edge: feature[name], predicate: NS::SCHEMA.image, iri: "#{Rails.application.config.frontend_url}/assets/features/#{name}.jpg")
      end

      faq = CreativeWork.create!(parent: thing, publisher_id: User::SERVICE_ID, creator_id: Profile::SERVICE_ID, is_published: true, display_name: 'Vragen')
      Property.create!(edge: thing, predicate: NS::ARGU[:faq], linked_edge: faq)

      I18n.available_locales.each do |locale|
        I18n.with_locale(locale) do
          Property.create!(edge: thing, predicate: NS::SCHEMA.name, string: 'Argu', language: locale)
          Property.create!(edge: thing, predicate: NS::SCHEMA.description, string: I18n.t('landing.header.title'), language: locale)
          Property.create!(edge: step_identify, predicate: NS::SCHEMA.name, string: I18n.t('landing.triad.identify.name'), language: locale)
          Property.create!(edge: step_identify, predicate: NS::SCHEMA.description, string: I18n.t('landing.triad.identify.header'), language: locale)
          Property.create!(edge: step_identify, predicate: NS::SCHEMA.text, string: I18n.t('landing.triad.identify.body'), language: locale)
          Property.create!(edge: feature_survey, predicate: NS::SCHEMA.name, string: I18n.t('landing.concept.surveys.custom_title'), language: locale)
          Property.create!(edge: feature_survey, predicate: NS::SCHEMA.text, string: I18n.t('landing.concept.surveys.custom_body'), language: locale)
          Property.create!(edge: feature_consulting, predicate: NS::SCHEMA.name, string: I18n.t('landing.concept.surveys.guidance_title'), language: locale)
          Property.create!(edge: feature_consulting, predicate: NS::SCHEMA.text, string: I18n.t('landing.concept.surveys.guidance_body'), language: locale)
          Property.create!(edge: feature_challenge, predicate: NS::SCHEMA.name, string: I18n.t('landing.concept.surveys.challenge_title'), language: locale)
          Property.create!(edge: feature_challenge, predicate: NS::SCHEMA.text, string: I18n.t('landing.concept.surveys.challenge_body'), language: locale)
          Property.create!(edge: step_cocreate, predicate: NS::SCHEMA.name, string: I18n.t('landing.triad.cocreate.name'), language: locale)
          Property.create!(edge: step_cocreate, predicate: NS::SCHEMA.description, string: I18n.t('landing.triad.cocreate.header'), language: locale)
          Property.create!(edge: step_cocreate, predicate: NS::SCHEMA.text, string: I18n.t('landing.triad.cocreate.body'), language: locale)
          Property.create!(edge: feature_crowdsource_innovation, predicate: NS::SCHEMA.name, string: I18n.t('landing.concept.challenges.crowdsource_innovation_title'), language: locale)
          Property.create!(edge: feature_crowdsource_innovation, predicate: NS::SCHEMA.text, string: I18n.t('landing.concept.challenges.crowdsource_innovation_body'), language: locale)
          Property.create!(edge: feature_structure, predicate: NS::SCHEMA.name, string: I18n.t('landing.concept.challenges.structure_title'), language: locale)
          Property.create!(edge: feature_structure, predicate: NS::SCHEMA.text, string: I18n.t('landing.concept.challenges.structure_body'), language: locale)
          Property.create!(edge: feature_reward, predicate: NS::SCHEMA.name, string: I18n.t('landing.concept.challenges.reward_title'), language: locale)
          Property.create!(edge: feature_reward, predicate: NS::SCHEMA.text, string: I18n.t('landing.concept.challenges.reward_body'), language: locale)
          Property.create!(edge: step_decide, predicate: NS::SCHEMA.name, string: I18n.t('landing.triad.decide.name'), language: locale)
          Property.create!(edge: step_decide, predicate: NS::SCHEMA.description, string: I18n.t('landing.triad.decide.header'), language: locale)
          Property.create!(edge: step_decide, predicate: NS::SCHEMA.text, string: I18n.t('landing.triad.decide.body'), language: locale)
          Property.create!(edge: feature_arguments, predicate: NS::SCHEMA.name, string: I18n.t('landing.concept.ideas.arguments_title'), language: locale)
          Property.create!(edge: feature_arguments, predicate: NS::SCHEMA.text, string: I18n.t('landing.concept.ideas.arguments_body'), language: locale)
          Property.create!(edge: feature_voting, predicate: NS::SCHEMA.name, string: I18n.t('landing.concept.ideas.voting_title'), language: locale)
          Property.create!(edge: feature_voting, predicate: NS::SCHEMA.text, string: I18n.t('landing.concept.ideas.voting_body'), language: locale)
          Property.create!(edge: feature_decide, predicate: NS::SCHEMA.name, string: I18n.t('landing.concept.ideas.decide_title'), language: locale)
          Property.create!(edge: feature_decide, predicate: NS::SCHEMA.text, string: I18n.t('landing.concept.ideas.decide_body'), language: locale)
          Property.create!(edge: case_heerenveen, predicate: NS::SCHEMA.name, string: I18n.t('landing.cases.heerenveen.title'), language: locale)
          Property.create!(edge: case_heerenveen, predicate: NS::SCHEMA.text, string: I18n.t('landing.cases.heerenveen.body'), language: locale)
          Property.create!(edge: case_heerenveen, predicate: NS::ARGU[:caseTitle], string: I18n.t('landing.cases.heerenveen.case_preview'), language: locale)
          Property.create!(edge: case_rochdale, predicate: NS::SCHEMA.name, string: I18n.t('landing.cases.rochdale.title'), language: locale)
          Property.create!(edge: case_rochdale, predicate: NS::SCHEMA.text, string: I18n.t('landing.cases.rochdale.body'), language: locale)
          Property.create!(edge: case_rochdale, predicate: NS::ARGU[:caseTitle], string: I18n.t('landing.cases.rochdale.case_preview'), language: locale)
          Property.create!(edge: case_hollandskroon, predicate: NS::SCHEMA.name, string: I18n.t('landing.cases.hollandskroon.title'), language: locale)
          Property.create!(edge: case_hollandskroon, predicate: NS::SCHEMA.text, string: I18n.t('landing.cases.hollandskroon.body'), language: locale)
          Property.create!(edge: case_hollandskroon, predicate: NS::ARGU[:caseTitle], string: I18n.t('landing.cases.hollandskroon.case_preview'), language: locale)
          Property.create!(edge: case_utrecht, predicate: NS::SCHEMA.name, string: I18n.t('landing.cases.utrecht.title'), language: locale)
          Property.create!(edge: case_utrecht, predicate: NS::SCHEMA.text, string: I18n.t('landing.cases.utrecht.body'), language: locale)
          Property.create!(edge: case_utrecht, predicate: NS::ARGU[:caseTitle], string: I18n.t('landing.cases.utrecht.case_preview'), language: locale)
          features.each do |name|
            Property.create!(edge: feature[name], predicate: NS::SCHEMA.name, string: I18n.t("landing.features.#{name}.title"), language: locale)
            Property.create!(edge: feature[name], predicate: NS::SCHEMA.text, string: I18n.t("landing.features.#{name}.body"), language: locale)
          end
        end

        Page.argu.update!(primary_container_node: thing)
      end
    end
  end
end
