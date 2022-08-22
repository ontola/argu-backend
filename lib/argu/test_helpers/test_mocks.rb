# frozen_string_literal: true

module Argu
  module TestHelpers
    module TestMocks
      def create_email_mock(template, email, **options) # rubocop:disable Metrics/MethodLength
        email_only = options.delete(:email_only)
        tenant = options.delete(:tenant) || :argu
        recipient =
          email_only ? {email: email, language: /.+/} : {display_name: /.+/, id: /.+/, language: /.+/, email: email}
        stub_request(:post, Argu::Service.new(:email).expand_url("/#{tenant}/email/spi/emails"))
          .with(
            body: {
              email: {
                template: template,
                recipient: recipient,
                options: options.presence
              }.compact
            }
          )
      end

      def mapbox_mock
        stub_request(
          :post,
          "https://api.mapbox.com/tokens/v2/#{ENV['MAPBOX_USERNAME']}?access_token=#{ENV['MAPBOX_KEY']}"
        ).to_return(status: 200, body: {token: 'token'}.to_json)
      end

      def validate_valid_bearer_token(root: :argu)
        stub_request(:get, verify_token_template(root)).to_return(status: 200)
      end

      def validate_invalid_bearer_token(root: :argu)
        stub_request(:get, verify_token_template(root)).to_return(status: 404)
      end

      private

      def verify_token_template(root)
        Addressable::Template.new("#{Argu::Service.new(:token).expand_url("/#{root}/tokens/verify")}{?jwt}")
      end
    end
  end
end
