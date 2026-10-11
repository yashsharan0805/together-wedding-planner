# Copyright (C) 2024-2025 LibreWeddingPlanner contributors

# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'affinities' do
  include_context 'when API request is authenticated'

  before do
    create_list(:group, 2, wedding:)
    allow(ActsAsTenant).to receive(:current_tenant).and_return(wedding)
    allow(wedding).to receive(:needs_optimization!)
  end

  path '/{slug}/groups/affinities/reset' do
    parameter Swagger::Schema::SLUG

    post('reset affinities') do
      tags 'Affinities'
      security [{ oauth2: ['guests', 'guests:write'] }]
      description 'Reset all affinities to default values based on the distance between groups in the hierarchy.'

      response_empty200 do
        expect(wedding).to have_received(:needs_optimization!)
      end
    end
  end

  path '/{slug}/groups/{group_id}/affinities' do
    parameter Swagger::Schema::SLUG
    parameter name: 'group_id', in: :path, schema: { type: :string, format: :uuid }, description: 'group_id'

    get('list affinities') do
      tags 'Affinities'
      produces 'application/json'
      security [{ oauth2: ['guests'] }]

      response(200, 'successful') do
        schema type: :object, additionalProperties: { type: :number, minimum: 0, maximum: 2 }
        run_test!
      end

      let(:group_id) { Group.first.id }
    end
  end

  path '/{slug}/groups/{group_id}/affinities/default' do
    parameter Swagger::Schema::SLUG
    parameter name: 'group_id', in: :path, schema: { type: :string, format: :uuid }, description: 'group_id'

    get('calculate default affinity') do
      tags 'Affinities'
      produces 'application/json'
      security [{ oauth2: ['guests'] }]

      response(200, 'successful') do
        schema type: :object, additionalProperties: { type: :number, minimum: 0, maximum: 2 }
        run_test!
      end

      let(:group_id) { Group.first.id }
    end
  end

  path '/{slug}/groups/{group_id}/affinities/bulk_update' do
    parameter Swagger::Schema::SLUG
    parameter name: 'group_id', in: :path, schema: { type: :string, format: :uuid }, description: 'group_id'

    put('bulk update affinities') do
      tags 'Affinities'
      produces 'application/json'
      consumes 'application/json'
      security [{ oauth2: ['guests', 'guests:write'] }]
      parameter name: :body, in: :body, schema: {
        type: :object,
        required: [:affinities],
        properties: {
          affinities: {
            type: :array,
            items: {
              type: :object,
              required: %i[group_id affinity],
              properties: {
                group_id: { type: :string, format: :uuid, description: 'ID of the associated group' },
                affinity: { type: :number, minimum: 0, maximum: 2 }
              }
            }
          }
        }
      }

      let(:group_id) { Group.first.id }
      let(:body) do
        {
          affinities: [
            { group_id: Group.second.id, affinity: 1 }
          ]
        }
      end

      response_empty200 do
        expect(wedding).to have_received(:needs_optimization!)
      end
    end
  end
end
