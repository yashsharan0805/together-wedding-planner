# Copyright (C) 2024-2025 LibreWeddingPlanner contributors

# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'payments' do
  include_context 'when API request is authenticated'

  before do
    create(:expense, wedding:).tap do |expense|
      create_list(:payment, 2, expense:)
    end
  end

  path '/{slug}/payments' do
    post 'create payment' do
      tags 'Payments'
      consumes 'application/json'
      produces 'application/json'
      security [{ oauth2: ['expenses', 'expenses:write'] }]
      parameter Swagger::Schema::SLUG
      parameter name: :body, in: :body, schema: {
        type: :object,
        required: %i[payment],
        properties: {
          payment: {
            type: :object,
            required: %i[title amount expense_id],
            properties: {
              title: { type: :string },
              amount: { type: :number, format: :float },
              expense_id: { type: :string, format: :uuid },
              cost_center_id: { type: :string, format: :uuid }
            }
          }
        }
      }

      let(:body) do
        {
          payment: {
            title: 'Deposit',
            amount: 100,
            expense_id: Expense.first.id
          }
        }
      end

      response_empty201
      response400
      regular_api_responses
    end
  end

  path '/{slug}/payments/{id}' do
    let(:id) { Payment.first.id }
    let(:new_cost_center) { create(:cost_center) }

    patch('update payment') do
      tags 'Payments'
      consumes 'application/json'
      produces 'application/json'
      security [{ oauth2: ['expenses', 'expenses:write'] }]
      parameter Swagger::Schema::SLUG
      parameter name: :id, in: :path, schema: { type: :string, format: :uuid }
      parameter name: :body, in: :body, schema: {
        type: :object,
        required: %i[payment],
        properties: {
          payment: {
            type: :object,
            required: %i[title amount expense_id],
            properties: {
              title: { type: :string },
              amount: { type: :number, format: :float },
              expense_id: { type: :string, format: :uuid },
              cost_center_id: { type: :string, format: :uuid }
            }
          }
        }
      }

      let(:body) do
        {
          payment: {
            title: 'New title',
            amount: 1234,
            cost_center_id: new_cost_center.id
          }
        }
      end

      response(200, 'Success') do
        produces 'application/json'
        schema type: :object
        run_test! do
          payment = Payment.find(id)

          expect(payment.title).to eq('New title')
          expect(payment.amount).to eq(1234)
          expect(payment.cost_center).to eq(new_cost_center)
        end
      end

      response400
      regular_api_responses
    end

    delete('delete payment') do
      tags 'Payments'
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
