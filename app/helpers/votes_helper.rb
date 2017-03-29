# frozen_string_literal: true
module VotesHelper
  def toggle_vote_link(model, vote)
    url = vote.try(:persisted?) ? vote_path(vote) : polymorphic_url([model, :votes], for: :pro)
    data = {remote: true, method: :post, title: t('tooltips.argument.vote_up')}
    if vote.present?
      data[:method] = :delete
      data['voted-on'] = true
      data[:title] = t('tooltips.argument.vote_up_undo')
    end

    link_to url, rel: :nofollow, class: 'upvote btn-subtle btn--mini tooltip tooltip--left', data: data do
      yield
    end
  end

  def icon_for_side(side)
    case side
    when 'pro'
      'thumbs-up'
    when 'neutral'
      'pause'
    when 'con'
      'thumbs-down'
    end
  end
end
