class SetDirectReactionsEmail < ActiveRecord::Migration[5.0]
  def change
    User
      .never_reactions_email
      .direct_news_email
      .direct_decisions_email
      .where('users.created_at < ?', Date.parse('06/07/2016'))
      .update_all(reactions_email: User.reactions_emails[:direct_reactions_email],
                  notifications_viewed_at: DateTime.current)
  end
end
