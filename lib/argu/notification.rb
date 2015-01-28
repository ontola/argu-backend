class Argu::Notification
  include Sidekiq::Worker
  include MailerHelper

  def perform(activity_id)
    a = Activity.find_by_id activity_id

    set_locale

    # TODO: split by locale
    if a.present? && a.trackable.respond_to?(:mailable?)
      mail_recipients = a.trackable.mailer.new(a).collect_recipients
      mailer = Mailer.new
      logger.info "Notificatie naar: #{mail_recipients.to_s}"
      mailer.send_message(mail_recipients, subject(a), mailer.render(view(a.trackable)))
    end
  end

  def set_locale
    I18n.locale = I18n.default_locale
  end

  def subject(activity)
    I18n.t('mailer.subject', type: I18n.t("#{activity.trackable.class_name}.type"),
                             item: I18n.t("#{activity.recipient.class_name}.type"))
  end

  def view(model)
    "app/views/mailer/direct/#{model.class_name}.html.slim"
  end

end