# frozen_string_literal: true

@actions = HashWithIndifferentAccess.new
%w[Page Forum Question Motion LinkedRecord Argument
   Comment VoteEvent Vote BlogPost Decision].each do |type|
  %w[create show update destroy trash]
    .each do |action|
    @actions["#{type.underscore}_#{action}"] =
      PermittedAction.create!(
        title: "#{type.underscore}_#{action}",
        resource_type: type,
        parent_type: '*',
        action: action.split('_').first
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

show_actions = %i[page_show forum_show question_show motion_show linked_record_show argument_show
                  comment_show vote_event_show vote_show blog_post_show decision_show].map { |a| @actions[a] }

spectate = GrantSet.new(title: 'spectator')
spectate.permitted_actions << show_actions
spectate.save!(validate: false)

participate = GrantSet.new(title: 'participator')
participate.permitted_actions << show_actions
participate.permitted_actions <<
  %i[motion_with_question_create argument_create comment_create vote_create].map { |a| @actions[a] }
participate.save!(validate: false)

initiate = GrantSet.new(title: 'initiator')
initiate.permitted_actions << show_actions
initiate.permitted_actions <<
  %i[question_create motion_create argument_create comment_create vote_create].map { |a| @actions[a] }
initiate.save!(validate: false)

moderate = GrantSet.new(title: 'moderator')
moderate.permitted_actions << show_actions
moderate.permitted_actions <<
  %i[question_create motion_create argument_create comment_create
     vote_create blog_post_create decision_create].map { |a| @actions[a] }
moderate.permitted_actions <<
  %i[question_update motion_update argument_update
     blog_post_update decision_update].map { |a| @actions[a] }
moderate.permitted_actions <<
  %i[question_trash motion_trash argument_trash blog_post_trash comment_trash].map { |a| @actions[a] }
moderate.save!(validate: false)

administrate = GrantSet.new(title: 'administrator')
administrate.permitted_actions << show_actions
administrate.permitted_actions <<
  %i[question_create motion_create argument_create comment_create
     vote_create blog_post_create decision_create].map { |a| @actions[a] }
administrate.permitted_actions <<
  %i[page_update forum_update question_update motion_update
     argument_update blog_post_update decision_update].map { |a| @actions[a] }
administrate.permitted_actions <<
  %i[question_trash motion_trash argument_trash blog_post_trash comment_trash].map { |a| @actions[a] }
administrate.permitted_actions <<
  %i[page_destroy forum_destroy].map { |a| @actions[a] }
administrate.save!(validate: false)

staff = GrantSet.new(title: 'staff')
staff.permitted_actions << show_actions
staff.permitted_actions <<
  %i[forum_create question_create motion_create argument_create
     comment_create vote_create blog_post_create decision_create].map { |a| @actions[a] }
staff.permitted_actions <<
  %i[page_update forum_update question_update motion_update
     argument_update blog_post_update decision_update].map { |a| @actions[a] }
staff.permitted_actions <<
  %i[question_trash motion_trash argument_trash blog_post_trash comment_trash].map { |a| @actions[a] }
staff.permitted_actions <<
  %i[page_destroy forum_destroy question_destroy motion_destroy argument_destroy
     blog_post_destroy comment_destroy].map { |a| @actions[a] }
staff.save!(validate: false)
