# Copyright (C) 2024-2025 LibreWeddingPlanner contributors

# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'summary' do
  include_context 'when API request is authenticated'

  path '/{slug}/summary' do
    get('list summaries') do
      tags 'Summary'
      produces 'application/json'
      consumes 'application/json'
      security [{ oauth2: %w[guests expenses] }]
      parameter Swagger::Schema::SLUG
      response(200, 'successful') do
        schema type: :object,
               required: %i[expenses guests],
               properties: {
                 expenses: {
                   type: :object,
                   required: %i[projected confirmed status],
                   properties: {
                     projected: {
                       type: :object,
                       required: %i[total guests],
                       properties: {
                         total: { type: :string },
                         guests: { type: :number }
                       }
                     },
                     confirmed: {
                       type: :object,
                       required: %i[total guests],
                       properties: {
                         total: { type: :string },
                         guests: { type: :number }
                       }
                     },
                     status: {
                       type: :object,
                       required: [:paid],
                       properties: {
                         paid: { type: :string }
                       }
                     }
                   }
                 },
                 guests: {
                   type: :object,
                   required: %i[total confirmed declined tentative invited],
                   properties: {
                     total: { type: :number },
                     confirmed: { type: :number },
                     declined: { type: :number },
                     tentative: { type: :number },
                     invited: { type: :number }
                   }
                 }
               }
        run_test!
      end
    end
  end
end
