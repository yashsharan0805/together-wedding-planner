# Copyright (C) 2024-2025 LibreWeddingPlanner contributors

# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'locations' do
  include_context 'when API request is authenticated'

  before do
    create_list(:location, 2, wedding:)
  end

  path '/{slug}/locations' do
    get('list locations') do
      tags 'Locations'
      produces 'application/json'
      security [{ oauth2: ['locations'] }]
      parameter Swagger::Schema::SLUG

      response(200, 'successful') do
        schema type: :array,
               items: { allOf: [{ '$ref' => '#/components/schemas/id' }, { '$ref' => '#/components/schemas/location' }] }

        run_test!
      end
      regular_api_responses
    end

    post 'create location' do
      tags 'Locations'
      consumes 'application/json'
      produces 'application/json'
      security [{ oauth2: ['locations', 'locations:write'] }]
      parameter Swagger::Schema::SLUG
      parameter name: :body, in: :body, schema: {
        type: :object,
        required: %i[location],
        properties: {
          location: { '$ref' => '#/components/schemas/location' }
        }
      }

      let(:body) do
        {
          location: {
            place_id: 5_326_784,
            latitude: '40.4169',
            longitude: '3.7033',
            label: 'Ceremony',
            display_name: 'Madrid, Community of Madrid, Spain'
          }
        }
      end

      response_empty201
      response400
      regular_api_responses
    end
  end

  path '/{slug}/locations/{id}' do
    let(:id) { Location.first.id }

    delete('delete location') do
      tags 'Locations'
      produces 'application/json'
      security [{ oauth2: ['locations', 'locations:write'] }]
      parameter Swagger::Schema::SLUG
      parameter Swagger::Schema::ID
      response_empty200
      response404
      regular_api_responses
    end
  end
end
