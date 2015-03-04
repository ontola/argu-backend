module MailerHelper
  def different_creator(a, b)
    a.creator.id != b.creator.id
  end
end