# frozen_string_literal: true

module Argu
  module TestHelpers
    module SearchkickMock
      def reindex(*_args, **_opts)
        super unless Thread.current[:mock_searchkick]
      end

      def store(_record)
        super unless Thread.current[:mock_searchkick]
      end
    end
  end
end

Searchkick::Index.prepend Argu::TestHelpers::SearchkickMock
Searchkick::RecordIndexer.prepend Argu::TestHelpers::SearchkickMock

module ElasticsearchAPIMock
  def bulk(_arguments = {})
    return super unless Thread.current[:mock_searchkick]

    {}
  end
end

Elasticsearch::Transport::Client.prepend ElasticsearchAPIMock
