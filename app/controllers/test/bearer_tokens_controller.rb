# frozen_string_literal: true
module Test
  class BearerTokensController < ActionController::Base
    def index
      render json: {
        data: [
          token(1),
          token(2)
        ]
      }
    end

    def create
      render json: {
        data: token(3)
      }
    end

    private

    def token(id)
      {
        id: id.to_s,
        type: 'tokens',
        attributes: {
          usages: 0,
          createdAt: DateTime.current,
          expiresAt: nil,
          retractedAt: nil
        },
        links: {
          url: "#{Rails.configuration.token_url}/#{id}"
        }
      }
    end
  end
end
