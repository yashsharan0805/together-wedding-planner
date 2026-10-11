# Copyright (C) 2024-2025 LibreWeddingPlanner contributors

# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'system/tasks' do
  include_context 'when API request is authenticated with system credentials'

  path '/system/tasks/{id}' do
    put('update task') do
      tags 'System'
      produces 'application/json'
      consumes 'application/json'
      security [{ oauth2: ['system'] }]
      description 'Update the simulation status of a task.'

      parameter name: :id, in: :path, schema: { type: :string, format: :uuid }
      parameter name: :body, in: :body, schema: {
        required: %i[status progress version discomfort],
        properties: {
          status: { type: :string, enum: %w[in_progress completed error] },
          progress: { type: :number, example: 0.85 },
          version: { type: :integer, minimum: 0, example: 35 },
          discomfort: { type: :string, description: 'The stringified float representing the discomfort',
                        example: '123.456' },
          solution: { '$ref' => '#/components/schemas/task_solution' }
        }
      }

      let(:simulation) { create(:tables_arrangement, optimized_version: 34, progress: 0.8, wedding:) }
      let(:id) { simulation.id }
      let(:people) { create_list(:guest, 8, wedding:, group: nil) }
      let(:body) do
        {
          status: :in_progress,
          progress: '0.85',
          version: 35,
          discomfort: 123.456,
          solution: [
            {
              id: SecureRandom.uuid_v4,
              capacity: { min: 8, max: 10 },
              people_ids: people.map(&:id),
              pinned_ids: people.first(2).map(&:id)
            }
          ]
        }
      end

      before do
        allow(WeddingPlanner.redis).to receive(:get).and_return(35)
      end

      response_empty200 do
        simulation.reload

        expect(simulation.tables.count).to eq(1)
        expect(simulation.guests.count).to eq(8)
        expect(simulation.guests.where(seats: { pinned: true }).count).to eq(2)
        expect(simulation.optimized_version).to eq(35)
        expect(simulation.progress).to be_within(0.01).of(0.85)
      end

      response(422, 'Simulation is now on a newer version') do
        before do
          allow(WeddingPlanner.redis).to receive(:get).and_return(36)
        end

        produces 'application/json'
        schema type: :object,
               properties: {
                 message: { type: :string }
               }
        run_test! do
          expect(response.parsed_body['message']).to eq('Solution sent for version 35 but current version is 36')
        end
      end
    end
  end

  path '/system/tasks/{id}/stats' do
    post('Register stats') do
      tags 'System'
      produces 'application/json'
      consumes 'application/json'
      security [{ oauth2: ['system'] }]
      description 'Store engine stats.'

      parameter name: :id, in: :path, schema: { type: :string, format: :uuid }
      parameter name: :body, in: :body, schema: {
        required: %i[stats],
        properties: {
          stats: {
            type: :object,
            properties: {
              evaluation_count: { type: :integer, minimum: 0 },
              iteration: { type: :integer, minimum: 0 },
              real_time: { type: :number, minimum: 0 },
              system_time: { type: :number, minimum: 0 },
              total_time: { type: :number, minimum: 0 },
              user_time: { type: :number, minimum: 0 }
            }
          }
        }
      }

      let(:simulation) { create(:tables_arrangement, wedding:) }
      let(:id) { simulation.id }
      let(:body) do
        {
          stats: {
            evaluation_count: 123_456,
            iteration: 12,
            real_time: 0.01,
            system_time: 0,
            total_time: 0.03,
            user_time: 0.02
          }
        }
      end

      # before do
      #   allow(WeddingPlanner.redis).to receive(:get).and_return(35)
      # end

      response_empty201 do
        stats = simulation.engine_stats.sole

        expect(stats.evaluation_count).to eq(123_456)
        expect(stats.iteration).to eq(12)
        expect(stats.real_time).to be_within(0.0001).of(0.01)
        expect(stats.system_time).to be_zero
        expect(stats.total_time).to be_within(0.0001).of(0.03)
        expect(stats.user_time).to be_within(0.0001).of(0.02)
      end
    end
  end
end
