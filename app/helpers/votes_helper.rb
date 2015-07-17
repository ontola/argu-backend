module VotesHelper

  def toggle_vote_link(model, vote, &block)
    url = vote.try(:persisted?) ? vote_path(vote) : polymorphic_url([model, :vote], for: :pro)
    data = {remote: true, method: :post, title: t('tooltips.argument.vote_up')}
    if vote.present?
      data[:method] = :delete
      data['voted-on'] = true
    end

    link_to url, rel: :nofollow, class: 'btn-subtle tooltip tooltip--left', data: data do
      yield
    end
  end
end
