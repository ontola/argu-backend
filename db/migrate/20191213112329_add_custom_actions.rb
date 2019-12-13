class AddCustomActions < ActiveRecord::Migration[5.2]
  include UriTemplateHelper

  def change
    return if Apartment::Tenant.current == 'public'

    creator = Profile.service
    publisher = User.service

    Page.find_each do |page|
      ActsAsTenant.with_tenant(page) do
        Widget.new_motion.includes(:owner).find_each do |widget|
          custom_action = CustomAction.create!(
            is_published: true,
            creator: creator,
            publisher: publisher,
            parent: widget.owner,
            href: new_iri(widget.owner, :motions),
            label_translation: true,
            label: 'motions.call_to_action.title',
            description_translation: true,
            description: 'motions.call_to_action.body',
            submit_label_translation: true,
            submit_label: 'motions.type_new'
          )
          widget.update!(resource_iri: [[custom_action.iri, nil]])
        end
        Widget.new_question.includes(:owner).find_each do |widget|
          custom_action = CustomAction.create!(
            is_published: true,
            creator: creator,
            publisher: publisher,
            parent: widget.owner,
            href: new_iri(widget.owner, :questions),
            label_translation: true,
            label: 'questions.call_to_action.title',
            description_translation: true,
            description: 'questions.call_to_action.body',
            submit_label_translation: true,
            submit_label: 'questions.type_new'
          )
          widget.update!(resource_iri: [[custom_action.iri, nil]])
        end
        Widget.new_topic.includes(:owner).find_each do |widget|
          custom_action = CustomAction.create!(
            is_published: true,
            creator: creator,
            publisher: publisher,
            parent: widget.owner,
            href: new_iri(widget.owner, :topics),
            label_translation: true,
            label: 'topics.call_to_action.title',
            description_translation: true,
            description: 'topics.call_to_action.body',
            submit_label_translation: true,
            submit_label: 'topics.type_new'
          )
          widget.update!(resource_iri: [[custom_action.iri, nil]])
        end
      end
    end

    PermittedAction.create_for_grant_sets('CustomAction', 'show', GrantSet.reserved)
    PermittedAction.create_for_grant_sets('CustomAction', 'create', GrantSet.reserved(only: %w[administrator staff]))
    PermittedAction.create_for_grant_sets('CustomAction', 'update', GrantSet.reserved(only: %w[administrator staff]))
    PermittedAction.create_for_grant_sets('CustomAction', 'trash', GrantSet.reserved(only: %w[administrator staff]))
    PermittedAction.create_for_grant_sets('CustomAction', 'destroy', GrantSet.reserved(only: %w[administrator staff]))
  end
end
