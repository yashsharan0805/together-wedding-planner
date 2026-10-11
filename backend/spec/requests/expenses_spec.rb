# Copyright (C) 2024-2025 LibreWeddingPlanner contributors

# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'expenses' do
  include_context 'when API request is authenticated'

  before do
    create_list(:expense, 2, wedding:)
  end

  path '/{slug}/expenses' do
    get('list expenses') do
      tags 'Expenses'
      produces 'application/json'
      security [{ oauth2: ['expenses'] }]
      parameter Swagger::Schema::SLUG

      response(200, 'successful') do
        schema type: :array,
               items: {
                 type: :object,
                 required: %i[id name amount pricing_type],
                 properties: {
                   id: { type: :string, format: :uuid },
                   **Swagger::Schema::EXPENSE
                 }
               }

        run_test!
      end
      regular_api_responses
    end

    post 'create expense' do
      tags 'Expenses'
      consumes 'application/json'
      produces 'application/json'
      security [{ oauth2: ['expenses', 'expenses:write'] }]
      parameter Swagger::Schema::SLUG
      parameter name: :body, in: :body, schema: {
        type: :object,
        required: %i[expense],
        properties: {
          expense: {
            type: :object,
            required: %i[name amount pricing_type],
            properties: Swagger::Schema::EXPENSE
          }
        }
      }

      let(:body) do
        {
          expense: {
            name: 'Photography',
            amount: 1500.0,
            pricing_type: 'fixed'
          }
        }
      end

      response_empty201
      response400
      regular_api_responses
    end
  end

  path '/{slug}/expenses/{id}' do
    let(:id) { Expense.first.id }
    patch('update expense') do
      tags 'Expenses'
      consumes 'application/json'
      produces 'application/json'
      security [{ oauth2: ['expenses', 'expenses:write'] }]
      parameter Swagger::Schema::SLUG
      parameter name: 'id', in: :path, schema: { type: :string, format: :uuid }, description: 'id'
      parameter name: :body, in: :body, schema: {
        type: :object,
        properties: Swagger::Schema::EXPENSE
      }

      let(:body) do
        {
          name: 'Catering',
          amount: 300.0,
          pricing_type: 'per_person'
        }
      end

      response_empty200
      response400
      response404
      regular_api_responses
    end

    delete('delete expense') do
      tags 'Expenses'
      produces 'application/json'
      security [{ oauth2: ['expenses', 'expenses:write'] }]
      parameter Swagger::Schema::SLUG
      parameter Swagger::Schema::ID
      response_empty200
      response404
      regular_api_responses
    end
  end
end
