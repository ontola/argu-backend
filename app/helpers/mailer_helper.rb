module MailerHelper
  include AlternativeNamesHelper, ProfilesHelper, MarkdownHelper

  def link_to_creator(object)
    link_to object.creator.display_name,
            dual_profile_url(object.creator),
            title: object.creator.display_name
  end

  def link_to_object(object, description = nil)
    link_to(description || type_for(object),
            object,
            title: object.display_name)
  end

  def action_path(item)
    "user_created_#{item.model_name.singular}"
  end

  def notification_subject(notification)
    if notification.renderable_resource?
      t("#{action_path(item)}",
        title: item.display_name,
        poster: item.creator.presence)
    else
      t('mailer.notifications_mailer.subject')
    end
  end

end
