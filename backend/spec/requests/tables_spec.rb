# Copyright (C) 2024-2025 LibreWeddingPlanner contributors

# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'tables' do
  include_context 'when API request is authenticated'

  before do
    create(:table_type, wedding:, capacity: 4..6, availability: 10)
    create(:table_type, wedding:, capacity: 2..4, availability: nil)

    create(:tables_arrangement, wedding:).tap do |simulation|
      simulation.tables.create!(capacity: 2..4, name: 'Friends')
    end
  end

  let(:tables_arrangement_id) { wedding.tables_arrangements.first.id }

  path '/{slug}/tables_arrangements/{tables_arrangement_id}/tables' do
    post('Create a new table') do
      tags 'Tables'
      produces 'application/json'
      consumes 'application/json'
      security [{ oauth2: ['simulations', 'simulations:write'] }]
      parameter Swagger::Schema::SLUG
      parameter name: :tables_arrangement_id, in: :path, schema: { type: :string, format: :uuid }
      response(200, 'successful') do
        schema type: :object
        run_test!
      end
      regular_api_responses
    end
  end

  path '/{slug}/tables_arrangements/{tables_arrangement_id}/tables/{id}' do
    let(:id) { Table.first.id }

    let(:body) do
      {
        table: { name: 'Family' }
      }
    end

    patch('Update a table') do
      tags 'Tables'
      produces 'application/json'
      consumes 'application/json'
      security [{ oauth2: ['simulations', 'simulations:write'] }]
      parameter Swagger::Schema::SLUG
      parameter name: :tables_arrangement_id, in: :path, schema: { type: :string, format: :uuid }
      parameter name: :id, in: :path, schema: { type: :string, format: :uuid }
      parameter name: :body, in: :body, schema: {
        type: :object,
        required: %i[table],
        properties: {
          table: {
            type: :object,
            required: %i[name],
            properties: {
              name: { type: :string }
            }
          }
        }
      }
      response(200, 'successful') do
        schema type: :object
        run_test!
      end
      regular_api_responses
    end
  end
end
