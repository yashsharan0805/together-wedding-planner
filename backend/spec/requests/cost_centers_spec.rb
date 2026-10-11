# Copyright (C) 2024-2025 LibreWeddingPlanner contributors

# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'cost center' do
  include_context 'when API request is authenticated'

  before do
    create_list(:cost_center, 2, wedding:)
    expense = create(:expense, wedding:)
    create(:payment, wedding:, expense:, amount: 100)
  end

  path '/{slug}/cost_centers' do
    get('list cost centers') do
      tags 'Cost centers'
      produces 'application/json'
      security [{ oauth2: ['expenses'] }]
      parameter Swagger::Schema::SLUG
      response(200, 'successful') do
        schema type: :array,
               items: {
                 type: :object,
                 required: %i[id name],
                 properties: {
                   id: { type: :string, format: :uuid },
                   name: { type: :string }
                 }
               }
        run_test!
      end
      regular_api_responses
    end

    post('create cost center') do
      tags 'Cost centers'
      consumes 'application/json'
      produces 'application/json'
      security [{ oauth2: ['expenses', 'expenses:write'] }]
      parameter Swagger::Schema::SLUG
      parameter name: :body, in: :body, schema: {
        type: :object,
        required: %i[cost_center],
        properties: {
          cost_center: {
            type: :object,
            required: %i[name],
            properties: {
              name: { type: :string }
            }
          }
        }
      }
      response(201, 'created') do
        schema type: :object, properties: {}

        let(:body) do
          {
            cost_center: {
              name: 'New cost center'
            }
          }
        end

        run_test!
      end
      regular_api_responses
    end
  end

  path '/{slug}/cost_centers/{id}' do
    let(:id) { CostCenter.first.id }
    put('update cost center') do
      tags 'Cost centers'
      consumes 'application/json'
      produces 'application/json'
      security [{ oauth2: ['expenses', 'expenses:write'] }]
      parameter Swagger::Schema::SLUG
      parameter name: :id, in: :path, schema: { type: :string, format: :uuid }
      parameter name: :body, in: :body, schema: {
        type: :object,
        required: %i[cost_center],
        properties: {
          cost_center: {
            type: :object,
            required: %i[name],
            properties: {
              name: { type: :string }
            }
          }
        }
      }
      response(200, 'updated') do
        schema type: :object, properties: {}

        let(:body) do
          {
            cost_center: {
              name: 'Updated cost center name'
            }
          }
        end

        run_test!
      end
      regular_api_responses
    end

    delete('delete cost center') do
      tags 'Cost centers'
      produces 'application/json'
      security [{ oauth2: ['expenses', 'expenses:write'] }]
      parameter Swagger::Schema::SLUG
      parameter name: :id, in: :path, schema: { type: :string, format: :uuid }

      response_empty200
      regular_api_responses
    end
  end

  path '/{slug}/cost_centers/stats' do
    get('cost center statistics') do
      tags 'Cost centers'
      produces 'application/json'
      parameter Swagger::Schema::SLUG
      security [{ oauth2: ['expenses'] }]
      response(200, 'stats retrieved') do
        schema type: :array, items: {
          type: :object,
          required: %i[name count sum],
          properties: {
            name: { type: :string, nullable: true },
            count: { type: :number, minimum: 0 },
            sum: { type: :string }
          }
        }

        run_test!
      end
      regular_api_responses
    end
  end
end
