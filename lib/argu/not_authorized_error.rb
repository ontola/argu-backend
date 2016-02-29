
module Argu
  class NotAuthorizedError < Pundit::Error
    attr_reader :query, :record, :policy, :verdict

    def initialize(options = {})
      if options.is_a? String
        message = options
      else
        @query  = options[:query]
        @record = options[:record]
        @policy = options[:policy]
        @verdict = options[:verdict]

        message = options.fetch(:message) { "not allowed to #{query} this #{record.inspect}" }
      end

      super(message)
    end
  end
end
