class Argu::Notification
  include Sidekiq::Worker
  include MailerHelper

  def perform(activity_id)
    a = Activity.find_by_id activity_id

    set_locale

    # TODO: split by locale
    if a.present? && a.trackable.respond_to?(:mailable?)
      mailer = ActivityMailer.new(a)
      #mail_recipients = mailer.collect_recipients # a.trackable.mailer.new(a).collect_recipients
      #mailer = Mailer.new
      logger.info "Notificatie naar: #{mail_recipients.to_s}"
      mailer.send! #mailer.send_message(mail_recipients, subject(a), mailer.render(view(a.trackable)))
    end
  end

  def set_locale
    I18n.locale = I18n.default_locale
  end



  def view(model)

  end

end