module MailerHelper
  include NamesHelper, ProfilesHelper, MarkdownHelper, EmailActionsHelper

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
    "user_created_#{item.resource.model_name.singular}"
  end

  def notification_subject(notification)
    if notification.renderable?
      opts = {
        title: notification.resource.display_name,
        poster: notification.resource.creator.display_name,
        parent_title: notification.activity.recipient.display_name
      }
      opts[:pro] = I18n.t(notification.resource.pro ? 'pro' : 'con') if notification.resource.respond_to?(:pro)
      I18n.t("mailer.user_mailer.#{action_path(notification)}.subject", opts)
    else
      I18n.t('mailer.notifications_mailer.subject')
    end
  end
end
