# Copyright (C) 2024-2025 LibreWeddingPlanner contributors

# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'engine' do
  include_context 'when API request is authenticated'

  before do
    allow(Redis).to receive(:new).and_return(instance_double(Redis, set: 'OK'))
  end

  path '/{slug}/engine/heartbeat' do
    post('send heartbeat ping') do
      tags 'Engine'
      produces 'application/json'
      security [{ oauth2: ['engine:write'] }]
      parameter Swagger::Schema::SLUG
      response(200, 'successful') do
        schema type: :object
        run_test!
      end
      regular_api_responses
    end
  end
end
