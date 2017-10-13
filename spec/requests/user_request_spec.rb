# spec/integration/blogs_spec.rb
require 'swagger_helper'

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Users API' do
  path '/users' do

    post 'Creates a user' do
      tags 'Users'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :user,
                in: :body,
                schema: {
                  type: :object,
                  properties: {
                    user: {
                      type: :object,
                      properties: {
                        email: {
                          format: :email,
                          type: :string
                        }
                      }
                    }
                  },
                  required: ['email']
                }

      response '201', 'user created' do
        let(:user) { {user: {email: 'user@argu.co'}} }

        run_test!
      end

      response '409', 'email taken' do
        let!(:other_user) { create(:user) }
        let(:user) { {user: {email: other_user.email}} }

        schema allOf: [
          {'$ref' => '#/definitions/error_handling_json_error'},
          {
            type: :object,
            properties: {
              message: {
                type: :string,
                enum: ['has already been taken']
              }
            }
          }
        ]

        run_test!
      end

      response '422', 'invalid email given' do
        let(:user) { {user: {email: 'invalid'}} }

        schema allOf: [
          {'$ref' => '#/definitions/error_handling_json_error'},
          {
            type: :object,
            properties: {
              message: {
                type: :string,
                enum: [
                  'is invalid',
                  "can't be blank"
                ]
              }
            }
          }
        ]

        run_test!
      end
    end
  end
end
