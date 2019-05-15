# frozen_string_literal: true

module RDF
  class LazySequence < LinkedRails::Sequence
    def members
      @_members ||= @members.call
    end
  end
end
