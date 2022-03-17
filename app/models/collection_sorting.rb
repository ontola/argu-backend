# frozen_string_literal: true

class CollectionSorting < LinkedRails::Collection::Sorting
  def sort_value
    return pro_votes_sorting if pro_votes_sorting?
    return children_count_sorting if children_count_sorting?

    super
  end

  private

  def children_count_sorting
    Edge.order_child_count_sql(attribute_name.to_s.gsub('_count', ''), direction: direction, as: :edges)
  end

  def children_count_sorting?
    attribute_name.to_s.ends_with?('_count') && attribute_name.to_sym != :follows_count
  end

  def pro_votes_sorting
    as = association_class == Motion && attribute_name.to_sym == :votes_pro_count ? :default_vote_events_edges : :edges
    vocab = association_class == Motion ? Vocabulary.vote_options : Vocabulary.upvote_options
    pro_vote_option = vocab.active_terms.find_by(exact_match: NS.argu[:yes])

    Edge.order_child_count_sql(pro_vote_option.uuid, direction: direction, as: as)
  end

  def pro_votes_sorting?
    key == NS.argu[:votesProCount]
  end
end
