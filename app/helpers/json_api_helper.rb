# frozen_string_literal: true
module JsonApiHelper
  # @param [Integer] status HTML response code
  # @param [Array<Hash, String>] errors A list of errors
  # @return [Hash] JSONApi error hash to use in a render method
  def json_api_error(status, errors = nil)
    human_status = Rack::Utils::HTTP_STATUS_CODES[status]
    errors =
      case errors
      when Array
        errors.map do |error|
          error.is_a?(Hash) ? error.merge(status: human_status) : {status: human_status, message: error}
        end
      when ActiveModel::Errors
        errors.keys.map do |key|
          errors[key].map { |error| {status: human_status, source: {parameter: key}, message: error} }
        end.flatten
      when Hash
        [errors.merge(status: human_status)]
      when String
        [{status: human_status, message: errors}]
      else
        [{status: human_status}]
      end
    {
      json: {
        errors: errors
      },
      status: status
    }
  end

  def json_api_type
    controller_name
  end
end
