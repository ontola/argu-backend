module ActivityStringHelper
  include AlternativeNamesHelper, ProfilesHelper

  # Generates an activity string for an activity in the sense of: 'Foo responded to your Bar'
  # Params:
  # +activity+:: The Activity to generate the HRS for
  # +embedded_link+:: Set to true to embed an anchor link (defaults to false)
  def activity_string_for(activity, embedded_link= false)
    prepared_owner_string = owner_string(activity.owner, embedded_link)
    your = your(activity.trackable, activity.recipient)

    # noinspection RubyCaseWithoutElseBlockInspection
    case activity.trackable
      when Question
        as_for_questions_create activity.trackable, your, embedded_link
      when Motion
        as_for_motions_create activity.trackable, your, embedded_link
      when Argument
        as_for_arguments_create activity.trackable, your, embedded_link
      when Comment
        as_for_comments_create activity.trackable, your, embedded_link
      when Vote
        as_for_votes_create activity, prepared_owner_string, your, embedded_link
    end.html_safe
  end

  # :nodoc:
  def as_for_questions_create(question, your, embedded_link= false)
    thing = embedded_link ? link_to(question.forum.display_name, question.forum, title: question.forum.display_name) : question.forum.display_name
    activity_string = I18n.t("activities.questions.create#{your}", type: question_type(question.forum), thing: thing)
    "#{owner_string(question.creator, embedded_link)} #{activity_string}"
  end

  # :nodoc:
  def as_for_motions_create(motion, your, embedded_link= false)
    if motion.questions.present?
      item = motion.questions.first
      item_type = question_type(item.forum)
    else
      item = motion.forum
      item_type = I18n.t("#{item.class_name}.type")
    end
    thing = embedded_link ? link_to(item_type, item, title: item.display_name) : item_type
    activity_string = I18n.t("activities.motions.create#{your}", type: item_type, thing: thing)
    "#{owner_string(motion.creator, embedded_link)} #{activity_string}"
  end

  # :nodoc:
  def as_for_arguments_create(argument, your, embedded_link= false)
    thing = embedded_link ? link_to(type_for(argument.motion), argument.motion, title: argument.motion.display_name) : type_for(argument.motion)
    activity_string = I18n.t("activities.arguments.create#{your}", type: argument_type(argument.forum), thing: thing)
    "#{owner_string(argument.creator, embedded_link)} #{activity_string}"
  end

  # :nodoc:
  def as_for_comments_create(comment, your, embedded_link= false)
    commentable = comment.commentable
    thing = embedded_link ? link_to(type_for(commentable), commentable, title: commentable.display_name) : type_for(commentable)
    activity_string = I18n.t("activities.comments.create#{your}", thing: thing)
    "#{owner_string(comment.creator, embedded_link)} #{activity_string}"
  end

  # :nodoc:
  def as_for_votes_create(act, owner_string, your, embedded_link= false)
    thing = embedded_link ? link_to(type_for(act.trackable.voteable), act.trackable.voteable, title: act.trackable.voteable.display_name) : type_for(act.trackable.voteable)
    activity_string = I18n.t("activities.votes.voted.#{act.parameters[:for]}#{your}", thing: thing)
    "#{owner_string} #{activity_string}"
  end

  def owner_string(profile, embedded_link= false)
    embedded_link ? link_to(profile.display_name, dual_profile_url(profile)) : profile.display_name
  end

  def your(trackable, recipient)
    parent = (trackable.try(:parent) && trackable.parent) || recipient
    if defined?(current_user)
      parent.try(:creator) == current_user.profile ? '_your' : ''
    else
      ''
    end
  end

end
