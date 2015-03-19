module ActivityStringHelper
  include AlternativeNamesHelper

  def activity_string_for(activity, embedded_link= false)
    owner_string = embedded_link ? link_to(activity.owner.display_name, dual_profile_path(activity.owner)) : activity.owner.display_name

    parent = (activity.trackable.try(:parent) && activity.trackable.parent) || activity.recipient
    if defined?(current_user)
      your = parent.creator == current_user.profile ? '_your' : ''
    else
      your = ''
    end
    case activity.trackable
      when Question
        as_for_questions_create activity, owner_string, your, embedded_link
      when Motion
        as_for_motions_create activity, owner_string, your, embedded_link
      when Argument
        as_for_arguments_create activity, owner_string, your, embedded_link
      when Comment
        as_for_comments_create activity, owner_string, your, embedded_link
      when Vote
        as_for_votes_create activity, owner_string, your, embedded_link
    end
  end

  def as_for_questions_create(act, owner_string, your, embedded_link= false)
    thing = embedded_link ? link_to(act.recipient.display_name, act.recipient, title: act.recipient.display_name) : act.recipient.display_name
    activity_string = I18n.t("activities.questions.create#{your}", type: question_type(act.recipient), thing: thing)
    "#{owner_string} #{activity_string}"
  end

  def as_for_motions_create(act, owner_string, your, embedded_link= false)
    if act.trackable.questions.present?
      item = act.trackable.questions.first
      item_type = question_type(item.forum)
    else
      item = act.trackable.forum
      item_type = t("#{item.class_name}.type")
    end
    thing = embedded_link ? link_to(item_type, item, title: item.display_name) : item_type
    activity_string = I18n.t("activities.motions.create#{your}", type: item_type, thing: thing)
    "#{owner_string} #{activity_string}"
  end

  def as_for_arguments_create(act, owner_string, your, embedded_link= false)
    thing = embedded_link ? link_to(type_for(act.recipient), act.trackable.motion, title: act.trackable.motion.display_name) : type_for(act.recipient)
    activity_string = I18n.t("activities.arguments.create#{your}", type: argument_type(act.trackable.forum),thing: thing)
    "#{owner_string} #{activity_string}"
  end

  def as_for_comments_create(act, owner_string, your, embedded_link= false)
    commentable = act.trackable.commentable
    thing = embedded_link ? link_to(type_for(commentable), commentable, title: commentable.display_name) : type_for(commentable)
    activity_string = I18n.t("activities.comments.create#{your}", thing: thing)
    "#{owner_string} #{activity_string}"
  end

  def as_for_votes_create(act, owner_string, your, embedded_link= false)
    thing = embedded_link ? link_to(type_for(act.trackable.voteable), act.trackable.voteable, title: act.trackable.voteable.display_name) : type_for(act.trackable.voteable)
    activity_string = I18n.t("activities.votes.voted.#{act.parameters[:for]}#{your}", thing: thing)
    "#{owner_string} #{activity_string}"
  end

end
