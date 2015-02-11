class Argu::Notification
  include Sidekiq::Worker
  include MailerHelper

  def perform(activity_id)
    a = Activity.find_by_id activity_id

    set_locale

    # TODO: split by locale
    if a.present?
      mailer = Argu::ActivityMailer.new(a)
      mailer.send!
    end
  end

  def set_locale
    I18n.locale = I18n.default_locale
  end

end