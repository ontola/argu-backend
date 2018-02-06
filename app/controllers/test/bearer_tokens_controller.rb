# frozen_string_literal: true

module Test
  class BearerTokensController < ActionController::Base
    protect_from_forgery with: :exception
    include UrlHelper

    def index
      render json: {
        data: {
          id: argu_url('/tokens/email/g/1', filter: {group_id: 1, type: 'email'}),
          type: 'collections',
          attributes: {
            type: 'https://argu.co/ns/core#Collection',
            pageSize: 50,
            title: 'Tokens',
            totalCount: 2,
            first: argu_url('/tokens/email/g/1', filter: {group_id: 1, type: 'email'}, page: 1),
            last: argu_url('/tokens/email/g/1', filter: {group_id: 1, type: 'email'}, page: 1)
          },
          relationships: {
            viewSequence: {
              data: {
                id: '_:g70345879532200',
                type: 'rdfSequences'
              }
            }
          }
        },
        included: [
          {
            id: '_:g70345879532200',
            type: 'rdfSequences',
            relationships: {
              members: {
                data: [
                  {
                    id: argu_url('/tokens/email/g/1', filter: {group_id: 1, type: 'email'}, page: 1),
                    type: 'collections'
                  }
                ]
              }
            }
          },
          {
            id: argu_url('/tokens/email/g/1', filter: {group_id: 1, type: 'email'}, page: 1),
            type: 'collections',
            attributes: {
              type: 'https://argu.co/ns/core#Collection',
              pageSize: 50,
              title: 'Tokens',
              totalCount: 2
            },
            relationships: {
              memberSequence: {
                data: {
                  id: '_:g70345915729720',
                  type: 'rdfSequences'
                }
              }
            }
          },
          {
            id: '_:g70345915729720',
            type: 'rdfSequences',
            relationships: {
              members: {
                data: [
                  {
                    id: argu_url('/tokens/1'),
                    type: 'tokens'
                  },
                  {
                    id: argu_url('/tokens/2'),
                    type: 'tokens'
                  }
                ]
              }
            }
          },
          token(argu_url('/tokens/1')),
          token(argu_url('/tokens/2'))
        ]
      }
    end

    def create
      render json: {
        data: token(argu_url('/tokens/3'))
      }
    end

    private

    def token(id)
      {
        id: id.to_s,
        type: 'tokens',
        attributes: {
          usages: 0,
          createdAt: Time.current,
          expiresAt: nil,
          retractedAt: nil
        },
        links: {
          self: "#{Rails.configuration.token_url}/#{id}"
        }
      }
    end
  end
end
