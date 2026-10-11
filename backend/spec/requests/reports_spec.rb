# Copyright (C) 2024-2025 LibreWeddingPlanner contributors

# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'reports' do
  include_context 'when API request is authenticated'

  path '/{slug}/reports/{id}' do
    get('report') do
      tags 'Reports'
      produces 'application/json', 'text/csv'
      security [{ oauth2: ['guests'] }]
      parameter Swagger::Schema::SLUG
      parameter name: :id, in: :path, type: :string, example: :catering, description: 'Report ID'

      let(:id) { 'catering' }

      response(200, 'successful') do
        schema type: :object,
               required: %i[rows columns],
               properties: {
                 rows: {
                   type: :array,
                   items: {
                     type: :object,
                     required: %i[header field],
                     properties: {
                       header: { type: :string },
                       field: { type: :string }
                     }
                   }
                 },
                 columns: {
                   type: :array,
                   items: {
                     type: :object
                   }
                 }
               }
        run_test!
      end

      context 'when the report ID is unknown' do
        let(:id) { 'something-else' }

        response(404, 'not found') do
          schema '$ref' => '#/components/schemas/error'

          run_test! do
            expect(response.parsed_body).to eq(
              'message' => 'Unsupported report',
              'errors' => ['Report something-else not supported']
            )
          end
        end
      end

      regular_api_responses
    end
  end
end
