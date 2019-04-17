# frozen_string_literal: true

module SearchkickMock
  def reindex(*_args)
    super unless Thread.current[:mock_searchkick]
  end

  def store(_record)
    super unless Thread.current[:mock_searchkick]
  end
end

Searchkick::Index.send(:prepend, SearchkickMock)
