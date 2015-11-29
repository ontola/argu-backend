# @abstract Override `update_counter_chain` and/or `update_counters` for implementation.
# Small Interface module for supporting the not-so-very-well implemented active counter cache updating
# Especially for interactions count, since it spreads like a cancer up the lineage
module CounterChainable
  extend ActiveSupport::Concern

  module InstanceMethods
    # @abstract
    # Used to call `update_counter_chain` in the upward lineage.
    # @note Should always be called in a transaction since can leave the counts incorrect if an
    #       exception is thrown up the lineage chain.
    # @note Should be called from the appropriate lifecycle hooks
    # @return [Boolean] Whether the update succeeded for the chain
    def update_counter_chain
      raise 'Abstract method called'
    end

    # @abstract
    # Method implementing the counter updating for the current method
    # Usually called from `update_counter_chain`
    def update_counters
      raise 'Abstract method called'
    end
  end

end
