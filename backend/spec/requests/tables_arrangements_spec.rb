# Copyright (C) 2024-2025 LibreWeddingPlanner contributors

# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'tables_arrangements' do
  include_context 'when API request is authenticated'

  before do
    group = create(:group, wedding:, color: '#ff0000')
    guests = create_list(:guest, 2, wedding:, status: :invited, group:)
    create(:tables_arrangement, wedding:, status: :completed).tap do |arrangement|
      tables = create_list(:table, 2, tables_arrangement: arrangement, wedding:)
      guests.each_with_index do |guest, index|
        create(:seat, wedding:, guest:, tables_arrangement: arrangement, table: tables[index % 2], pinned: index.odd?)
      end
    end
  end

  path '/{slug}/tables_arrangements' do
    get('list tables arrangements') do
      tags 'Tables Arrangements'

      produces 'application/json'
      security [{ oauth2: ['simulations'] }]
      parameter Swagger::Schema::SLUG
      response(200, 'successful') do
        schema type: :array,
               items: {
                 type: :object,
                 required: %i[id discomfort status progress total_table_count],
                 properties: {
                   id: { type: :string, format: :uuid },
                   discomfort: { type: :number, nullable: true },
                   status: { type: :string, enum: %w[completed in_progress not_started error] },
                   progress: { type: :number },
                   total_table_count: { type: :integer, minimum: 0 },
                   system: { type: :boolean }
                 }
               }

        run_test!
      end
      regular_api_responses
    end
  end

  path '/{slug}/tables_arrangements/{id}' do
    let(:id) { TablesArrangement.first.id }
    get('show tables arrangement') do
      tags 'Tables Arrangements'
      produces 'application/json'
      security [{ oauth2: ['simulations'] }]
      parameter Swagger::Schema::SLUG
      parameter Swagger::Schema::ID
      response(200, 'successful') do
        schema type: :object,
               required: %i[id tables stats status progress],
               properties: {
                 id: { type: :string, format: :uuid },
                 status: { type: :string, enum: %w[completed in_progress not_started error] },
                 progress: { type: :number },
                 system: { type: :boolean },
                 stats: {
                   type: :object,
                   required: %i[evaluation_count time],
                   properties: {
                     evaluation_count: { type: :integer, minimum: 0 },
                     time: { type: :number, minimum: 0, nullable: true }
                   }
                 },
                 tables: {
                   type: :array,
                   items: {
                     type: :object,
                     required: %i[id name number guests discomfort capacity_limits],
                     properties: {
                       id: { type: :string, format: :uuid },
                       name: { type: :string, nullable: true },
                       number: { type: :integer, minimum: 1 },
                       guests: {
                         type: :array,
                         items: {
                           type: :object,
                           required: %i[id name color pinned],
                           properties: {
                             id: { type: :string, format: :uuid },
                             name: { type: :string },
                             color: { type: :string },
                             pinned: { type: :boolean }
                           }
                         }
                       },
                       discomfort: {
                         type: :object,
                         required: %i[discomfort breakdown],
                         properties: {
                           discomfort: { type: :number },
                           breakdown: {
                             type: :object,
                             required: %i[table_size_penalty cohesion_penalty],
                             properties: {
                               table_size_penalty: { type: :number },
                               cohesion_penalty: { type: :number },
                               invitations_penalty: { type: :number }
                             }
                           }
                         }
                       },
                       capacity_limits: { type: :object,
                                          required: %i[min max],
                                          properties: {
                                            min: { type: :integer, minimum: 1 },
                                            max: { type: :integer, minimum: 1 }
                                          } }
                     }
                   }
                 }
               }
        run_test! do
          expect(response.parsed_body['tables'].count).to eq(2)

          expect(response.parsed_body.dig('tables', 0, 'guests', 0, 'pinned')).to be(false)
          expect(response.parsed_body.dig('tables', 1, 'guests', 0, 'pinned')).to be(true)
        end
      end
      regular_api_responses
    end
  end

  path '/{slug}/tables_arrangements/{id}/move' do
    let(:id) { TablesArrangement.first.id }
    let(:body) do
      {
        guest_id: Guest.first.id,
        table_id: Table.first.id
      }
    end

    put('move guest to another table') do
      tags 'Tables Arrangements'
      produces 'application/json'
      consumes 'application/json'
      security [{ oauth2: ['simulations', 'simulations:write'] }]
      parameter Swagger::Schema::SLUG
      parameter Swagger::Schema::ID
      parameter name: :body,
                in: :body,
                schema: {
                  type: :object,
                  required: %i[guest_id table_id],
                  properties: {
                    guest_id: { type: :string, format: :uuid },
                    table_id: { type: :string, format: :uuid }
                  }
                }

      response(200, 'successful') do
        schema type: :object, properties: {}
        run_test!
      end

      regular_api_responses
    end
  end

  path '/{slug}/tables_arrangements/{id}/pin' do
    let(:id) { TablesArrangement.first.id }
    let(:body) do
      {
        guest_id: Guest.first.id,
        table_id: Table.first.id,
        pinned: true
      }
    end

    put('fix a guest to a given table within an simulation') do
      tags 'Tables Arrangements'
      produces 'application/json'
      consumes 'application/json'
      security [{ oauth2: ['simulations', 'simulations:write'] }]
      parameter Swagger::Schema::SLUG
      parameter Swagger::Schema::ID
      parameter name: :body,
                in: :body,
                schema: {
                  type: :object,
                  required: %i[guest_id table_id pinned],
                  properties: {
                    guest_id: { type: :string, format: :uuid },
                    table_id: { type: :string, format: :uuid },
                    pinned: { type: :boolean }
                  }
                }

      response(200, 'successful') do
        schema type: :object, properties: {}
        run_test!
      end

      regular_api_responses
    end
  end

  path '/{slug}/tables_arrangements/{id}/optimize' do
    let(:id) { TablesArrangement.first.id }

    post('optimize the simulation from the current status') do
      tags 'Tables Arrangements'
      produces 'application/json'
      consumes 'application/json'
      security [{ oauth2: ['simulations', 'simulations:write'] }]
      parameter Swagger::Schema::SLUG
      parameter Swagger::Schema::ID

      response(200, 'successful') do
        schema type: :object, properties: {}
        run_test!
      end

      regular_api_responses
    end
  end

  path '/{slug}/tables_arrangements/{id}/optimize' do
    let(:id) { TablesArrangement.first.id }

    post('remove all tables, seats, and start over') do
      tags 'Tables Arrangements'
      produces 'application/json'
      consumes 'application/json'
      security [{ oauth2: ['simulations', 'simulations:write'] }]
      parameter Swagger::Schema::SLUG
      parameter Swagger::Schema::ID

      response(200, 'successful') do
        schema type: :object, properties: {}
        run_test!
      end

      regular_api_responses
    end
  end
end
