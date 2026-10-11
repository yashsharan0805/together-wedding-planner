# Copyright (C) 2024-2025 LibreWeddingPlanner contributors

# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'buses' do
  include_context 'when API request is authenticated'

  before do
    create_list(:bus, 2)
  end

  path '/{slug}/buses' do
    get('lists buses available') do
      tags 'Buses'
      produces 'application/json'
      security [{ oauth2: ['buses'] }]
      parameter Swagger::Schema::SLUG
      response(200, 'successful') do
        schema type: :array,
               items: {
                 type: :object,
                 required: %i[id seats number],
                 properties: {
                   id: { type: :string, format: :uuid },
                   seats: { type: :integer, minimum: 1 },
                   number: { type: :integer, minimum: 1 }
                 }
               }
        run_test!
      end
      regular_api_responses
    end

    post('create bus') do
      tags 'Buses'
      consumes 'application/json'
      produces 'application/json'
      security [{ oauth2: ['buses', 'buses:write'] }]
      parameter Swagger::Schema::SLUG
      parameter name: :body, in: :body, schema: {
        type: :object,
        required: %i[bus],
        properties: {
          bus: {
            type: :object,
            required: %i[seats],
            properties: {
              seats: { type: :integer, minimum: 1 }
            }
          }
        }
      }

      let(:body) do
        {
          bus: {
            seats: 55
          }
        }
      end

      response_empty201
      response400
      regular_api_responses
    end
  end

  path '/{slug}/buses/{id}' do
    let(:id) { Bus.first.id }

    delete('delete bus') do
      tags 'Buses'
      produces 'application/json'
      security [{ oauth2: ['buses', 'buses:write'] }]
      parameter Swagger::Schema::SLUG
      parameter name: :id, in: :path, schema: { type: :string, format: :uuid }

      response_empty200
      response404
      regular_api_responses
    end
  end

  path '/{slug}/buses/stats' do
    get('get stats about buses feature') do
      tags 'Buses'
      produces 'application/json'
      security [{ oauth2: ['buses'] }]
      parameter Swagger::Schema::SLUG
      response(200, 'successful') do
        schema type: :object,
               required: %i[potential confirmed],
               properties: {
                 potential: { type: :integer, minimum: 0 },
                 confirmed: { type: :integer, minimum: 0 }
               }
        run_test!
      end
      regular_api_responses
    end
  end
end
