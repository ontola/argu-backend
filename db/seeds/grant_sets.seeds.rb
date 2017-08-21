# frozen_string_literal: true
@actions = HashWithIndifferentAccess.new
%w(Page Forum Source Question Motion LinkedRecord Argument Comment VoteEvent Vote BlogPost Decision).each do |type|
  %w(create create_moderate create_staff show update_moderate update_staff update_creator destroy trash)
    .each do |action|
    @actions["#{type.underscore}_#{action}"] =
      PermittedAction.create!(
        title: "#{type.underscore}_#{action}",
        resource_type: type,
        parent_type: '*',
        action: action.split('_').first,
        trickles: !action.include?('_creator')
      )
  end
end
%w(Motion).each do |type|
  %w(no_create)
    .each do |action|
    @actions["#{type.underscore}_#{action}"] =
      PermittedAction.create!(
        title: "#{type.underscore}_#{action}",
        resource_type: type,
        parent_type: '*',
        action: action.split('_').last,
        permit: false
      )
  end
end
@actions[:motion_with_question_create] =
  PermittedAction.create!(
    title: 'motion_with_question_create',
    resource_type: 'Motion',
    parent_type: 'Question',
    action: 'create'
  )

show_actions = %i(page_show forum_show source_show question_show motion_show linked_record_show argument_show
                  comment_show vote_event_show vote_show blog_post_show decision_show).map { |a| @actions[a] }

creator = GrantSet.new(title: 'creator')
creator.permitted_actions <<
  %i(question_update_creator motion_update_creator argument_update_creator comment_update_creator)
    .map { |a| @actions[a] }
creator.save!

spectate = GrantSet.new(title: 'spectator')
spectate.permitted_actions << show_actions
spectate.save!

participate = GrantSet.create!(title: 'participator')
participate.permitted_actions << show_actions
participate.permitted_actions <<
  %i(motion_with_question_create argument_create comment_create vote_create).map { |a| @actions[a] }
participate.save!

initiate = GrantSet.create!(title: 'initiator')
initiate.permitted_actions << show_actions
initiate.permitted_actions <<
  %i(question_create motion_create argument_create comment_create vote_create).map { |a| @actions[a] }
initiate.save!

moderate = GrantSet.create!(title: 'moderator')
moderate.permitted_actions << show_actions
moderate.permitted_actions <<
  %i(question_create_moderate motion_create_moderate argument_create_moderate comment_create_moderate
     vote_create_moderate blog_post_create_moderate decision_create_moderate).map { |a| @actions[a] }
moderate.permitted_actions <<
  %i(question_update_moderate motion_update_moderate argument_update_moderate
     blog_post_update_moderate decision_update_moderate).map { |a| @actions[a] }
moderate.permitted_actions <<
  %i(question_trash motion_trash argument_trash blog_post_trash comment_trash).map { |a| @actions[a] }
moderate.save!

administrate = GrantSet.create!(title: 'administrator')
administrate.permitted_actions << show_actions
administrate.permitted_actions <<
  %i(question_create_moderate motion_create_moderate argument_create_moderate comment_create_moderate
     vote_create_moderate blog_post_create_moderate decision_create_moderate).map { |a| @actions[a] }
administrate.permitted_actions <<
  %i(page_update_moderate forum_update_moderate source_update_moderate question_update_moderate motion_update_moderate
     argument_update_moderate blog_post_update_moderate decision_update_moderate).map { |a| @actions[a] }
administrate.permitted_actions <<
  %i(question_trash motion_trash argument_trash blog_post_trash comment_trash).map { |a| @actions[a] }
administrate.permitted_actions <<
  %i(page_destroy forum_destroy).map { |a| @actions[a] }
administrate.save!

staff = GrantSet.create!(title: 'staff')
staff.permitted_actions << show_actions
staff.permitted_actions <<
  %i(forum_create_staff source_create_staff question_create_staff motion_create_staff argument_create_staff
     comment_create_staff vote_create_staff blog_post_create_staff decision_create_staff).map { |a| @actions[a] }
staff.permitted_actions <<
  %i(page_update_staff forum_update_staff source_update_staff question_update_staff motion_update_staff
     argument_update_staff blog_post_update_staff decision_update_staff).map { |a| @actions[a] }
staff.permitted_actions <<
  %i(question_trash motion_trash argument_trash blog_post_trash comment_trash).map { |a| @actions[a] }
staff.permitted_actions <<
  %i(page_destroy forum_destroy source_destroy question_destroy motion_destroy argument_destroy
     blog_post_destroy comment_destroy).map { |a| @actions[a] }
staff.save!

def create_permitted_atributes(a, attrs)
  a.uniq.each do |action|
    PermittedAttribute.create!(attrs.map { |attr| {permitted_action: @actions[action], name: attr} })
  end
end

media_object_attrs =
  %i([id] [used_as] [content] [remote_content] [remove_content] [content_cache] [_destroy] [description]
     [content_attributes][position_y])
profile_attrs =
  %i(profile_attributes[id] profile_attributes[name] profile_attributes[are_votes_public] profile_attributes[is_public]
     profile_attributes[about])
    .concat(media_object_attrs.map { |attr| "profile_attributes[default_cover_photo_attributes]#{attr}" })
    .concat(media_object_attrs.map { |attr| "profile_attributes[default_profile_photo_attributes]#{attr}" })
expires_attrs =
  %i(edge_attributes[id] edge_attributes[expires_at])
publish_attrs =
  %i(edge_attributes[argu_publication_attributes][id]
     edge_attributes[argu_publication_attributes][publish_type]
     edge_attributes[argu_publication_attributes][published_at])

# Page attributes
page_attrs = %i(bio last_accepted visibility confirmation_string).concat(profile_attrs)
create_permitted_atributes(%w(page_update_moderate page_update_staff), page_attrs)

# Forum attributes
forum_attrs =
  %i(lock_version name bio bio_long profile_id locale public_grant)
    .concat(media_object_attrs.map { |attr| "default_cover_photo_attributes#{attr}" })
    .concat(media_object_attrs.map { |attr| "default_profile_photo_attributes#{attr}" })
create_permitted_atributes(%w(forum_update_moderate), forum_attrs)
create_permitted_atributes(
  %w(forum_create_staff forum_update_staff),
  %i(page_id max_shortname_count discoverable).concat(forum_attrs)
)

# Source attributes
source_attrs = %i(name iri_base shortname public_grant)
create_permitted_atributes(
  %w(source_update_moderate source_create_staff source_update_staff),
  source_attrs
)

# Question attributes
question_attrs =
  %i(title content cover_photo_attribution)
    .concat(media_object_attrs.map { |attr| "default_cover_photo_attributes#{attr}" })
    .concat(media_object_attrs.map { |attr| "default_profile_photo_attributes#{attr}" })
    .concat(media_object_attrs.map { |attr| "attachments_attributes#{attr}" })
    .concat(publish_attrs)
create_permitted_atributes(%w(question_create question_update_creator), question_attrs)
create_permitted_atributes(
  %w(question_create_moderate question_update_moderate),
  %i(pinned require_location mark_as_important).concat(expires_attrs).concat(question_attrs)
)
create_permitted_atributes(
  %w(question_create_staff question_update_staff),
  %i(pinned require_location mark_as_important include_motions f_convert).concat(expires_attrs).concat(question_attrs)
)

# Motion attributes
motion_attrs =
  %i(title content question_answers_attributes[id] question_answers_attributes[question_id]
     question_answers_attributes[motion_id])
    .concat(media_object_attrs.map { |attr| "default_cover_photo_attributes#{attr}" })
    .concat(media_object_attrs.map { |attr| "default_profile_photo_attributes#{attr}" })
    .concat(media_object_attrs.map { |attr| "attachments_attributes#{attr}" })
    .concat(publish_attrs)
create_permitted_atributes(%w(motion_create motion_update_creator), motion_attrs)
create_permitted_atributes(
  %w(motion_create_moderate motion_update_moderate),
  %i(pinned mark_as_important).concat(expires_attrs).concat(motion_attrs)
)
create_permitted_atributes(
  %w(motion_create_staff motion_update_staff),
  %i(pinned mark_as_important invert_arguments f_convert).concat(expires_attrs).concat(motion_attrs)
)

# Argument attributes
argument_attrs = %i(title content pro)
create_permitted_atributes(
  %w(argument_create argument_update_creator argument_create_moderate
     argument_update_moderate argument_create_staff argument_update_staff),
  argument_attrs
)

# Comment attributes
comment_attrs = %i(body parent_id)
create_permitted_atributes(
  %w(comment_create comment_update_creator comment_create_moderate comment_create_staff),
  comment_attrs
)

# Vote attributes
vote_attrs = %i(explanation argument_ids)
create_permitted_atributes(
  %w(vote_create vote_update_creator vote_create_moderate vote_create_staff),
  vote_attrs
)

# BlogPost attributes
blog_post_attrs = %i(title content happening_attributes[id] happening_attributes[happened_at])
                    .concat(media_object_attrs.map { |attr| "attachments_attributes#{attr}" })
                    .concat(publish_attrs)
create_permitted_atributes(
  %w(blog_post_create_moderate blog_post_update_moderate blog_post_create_staff blog_post_update_staff),
  blog_post_attrs
)

# Decision attributes
decision_attrs = %i(content happening_attributes[id] happening_attributes[happened_at])
                   .concat(publish_attrs)
create_permitted_atributes(
  %w(decision_update_moderate decision_update_staff),
  decision_attrs
)
create_permitted_atributes(
  %w(decision_create_moderate decision_create_staff),
  %i(state forwarded_user_id forwarded_group_id).append(decision_attrs)
)
