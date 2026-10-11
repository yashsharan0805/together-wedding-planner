# Copyright (C) 2024-2025 LibreWeddingPlanner contributors

# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'table_types' do
  include_context 'when API request is authenticated'

  before do
    create(:table_type, wedding:, capacity: 4..6, availability: 10)
    create(:table_type, wedding:, capacity: 2..4, availability: nil)
  end

  path '/{slug}/table_types' do
    get('list table types') do
      tags 'Table Types'
      produces 'application/json'
      security [{ oauth2: ['simulations'] }]
      parameter Swagger::Schema::SLUG
      response(200, 'successful') do
        schema type: :array,
               items: {
                 type: :object,
                 required: %i[id capacity_limits],
                 properties: {
                   id: { type: :string, format: :uuid },
                   capacity_limits: { type: :object,
                                      required: %i[min max],
                                      properties: {
                                        min: { type: :integer, minimum: 1 },
                                        max: { type: :integer, minimum: 1 }
                                      } },
                   availability: {
                     type: :integer,
                     minimum: 1,
                     nullable: true,
                     description: 'Number of units of this type available'
                   }
                 }
               }
        run_test!
      end
      regular_api_responses
    end

    post('create table type') do
      tags 'Table Types'
      consumes 'application/json'
      produces 'application/json'
      security [{ oauth2: ['simulations', 'simulations:write'] }]
      parameter Swagger::Schema::SLUG
      parameter name: :body, in: :body, schema: {
        type: :object,
        required: %i[table_type],
        properties: {
          table_type: {
            type: :object,
            required: %i[capacity_limits availability],
            properties: {
              capacity_limits: {
                type: :object,
                required: %i[min max],
                properties: {
                  min: { type: :integer, minimum: 1 },
                  max: { type: :integer, minimum: 1 }
                }
              },
              availability: {
                type: :integer,
                minimum: 1,
                nullable: true,
                description: 'Number of units of this type available'
              }
            }
          }
        }
      }

      let(:body) do
        {
          table_type: {
            capacity_limits: { min: 6, max: 8 },
            availability: 12
          }
        }
      end

      response_empty201
      response400
      regular_api_responses
    end
  end

  path '/{slug}/table_types/{id}' do
    let(:id) { TableType.first.id }
    # TODO: Document update

    delete('delete table type') do
      tags 'Table Types'
      produces 'application/json'
      security [{ oauth2: ['simulations', 'simulations:write'] }]
      parameter Swagger::Schema::SLUG
      parameter name: :id, in: :path, schema: { type: :string, format: :uuid }

      response_empty200
      response404
      regular_api_responses
    end
  end
end
