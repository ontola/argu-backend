# frozen_string_literal: true

module SearchkickMock
  def reindex(*_args)
    super unless Thread.current[:mock_searchkick]
  end

  def store(_record)
    super unless Thread.current[:mock_searchkick]
  end
end

Searchkick::Index.prepend SearchkickMock
Searchkick::RecordIndexer.prepend SearchkickMock

module ElasticsearchAPIMock
  def bulk(_arguments = {})
    return super unless Thread.current[:mock_searchkick]

    {}
  end
end

Elasticsearch::Transport::Client.prepend ElasticsearchAPIMock
