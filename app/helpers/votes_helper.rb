module VotesHelper

  def toggle_vote_link(model, vote, &block)
    url = vote.try(:persisted?) ? vote_path(vote) : polymorphic_url([model, :vote], for: :pro)
    data = {remote: true, method: :post, title: t('tooltips.argument.vote_up')}
    data[:method] = :delete if vote.present?

    link_to url, rel: :nofollow, class: "btn-subtle tooltip tooltip--left #{'btn-subtle-active' if vote.present?}", data: data do
      yield
    end
  end
end