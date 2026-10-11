# Copyright (C) 2024-2025 LibreWeddingPlanner contributors

# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'users' do
  path '/{slug}/users/{id}' do
    let(:id) { user.id }
    include_context 'when API request is authenticated'

    put('update user') do
      tags 'Users'
      consumes 'application/json'
      produces 'application/json'
      security [{ oauth2: ['users', 'users:write'] }]
      parameter Swagger::Schema::SLUG
      parameter name: :id, in: :path, schema: { type: :string, format: :uuid }
      parameter name: :body, in: :body, schema: {
        type: :object,
        required: %i[user],
        properties: {
          user: {
            type: :object,
            properties: {
              language: { type: :string, nullable: true, minLength: 2, maxLength: 2 }
            }
          }
        }
      }

      response(200, 'Success') do
        let(:body) { { user: { language: :es } } }
        schema type: :object

        run_test! do
          expect(user.reload.language).to eq('es')
        end
      end

      context "when the user ID is 'current'" do
        let(:id) { :current }

        response(200, 'Success') do
          let(:body) { { user: { language: :es } } }
          schema type: :object

          run_test! do
            expect(user.reload.language).to eq('es')
          end
        end
      end

      response(400, 'Validation errors in input parameters') do
        schema '$ref' => '#/components/schemas/error'
        let(:body) { { user: { language: :foobar } } }

        run_test! do
          expect(response.parsed_body['message']).to eq('Record invalid')
          expect(response.parsed_body['errors']).to contain_exactly('Language is the wrong length (should be 2 characters)')
        end
      end

      response(403, 'do not have permissions to update that user') do
        let(:id) { create(:user, wedding:).id }
        let(:body) { { user: { language: :es } } }
        schema type: :object

        run_test! do
          expect(user.reload.language).to be_nil
        end
      end
    end
  end

  path '/{slug}/users/whoami' do
    get('show information about the current user') do
      tags 'Users'
      produces 'application/json'
      parameter Swagger::Schema::SLUG

      response(200, 'successful') do
        include_context 'when API request is authenticated'
        schema type: :object,
               required: %i[id slug],
               properties: {
                 id: { type: :string, format: :uuid },
                 language: { type: :string, nullable: true, minLength: 2, maxLength: 2 },
                 slug: { type: :string },
                 email: { type: :string }
               }
        run_test!
      end

      response(401, 'user not authenticated') do
        let(:slug) { create(:wedding).slug }
        let(:Authorization) { nil } # rubocop:disable RSpec/VariableName
        schema '$ref' => '#/components/schemas/error'
        run_test!
      end
    end
  end
end
