# Copyright (C) 2024-2025 LibreWeddingPlanner contributors

# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'tasks' do
  include_context 'when API request is authenticated'

  before do
    create_list(:task, 2, wedding:)
  end

  path '/{slug}/tasks' do
    get('list tasks') do
      tags 'Tasks'
      produces 'application/json'
      security [{ oauth2: ['tasks'] }]
      parameter Swagger::Schema::SLUG

      response(200, 'successful') do
        schema type: :array,
               items: {
                 type: :object,
                 required: %i[id title completed_at],
                 properties: {
                   id: { type: :string, format: :uuid },
                   **Swagger::Schema::TASK
                 }
               }

        run_test!
      end
      regular_api_responses
    end

    post 'create task' do
      tags 'Tasks'
      consumes 'application/json'
      produces 'application/json'
      security [{ oauth2: ['tasks', 'tasks:write'] }]
      parameter Swagger::Schema::SLUG
      parameter name: :body, in: :body, schema: {
        type: :object,
        required: %i[task],
        properties: {
          task: {
            type: :object,
            required: %i[title],
            properties: Swagger::Schema::TASK
          }
        }
      }

      let(:body) do
        { task: { title: 'Buy roses' } }
      end

      response_empty201
      response400
      regular_api_responses
    end
  end

  path '/{slug}/tasks/{id}' do
    let(:id) { Task.first.id }
    patch('update task') do
      tags 'Tasks'
      consumes 'application/json'
      produces 'application/json'
      security [{ oauth2: ['tasks', 'tasks:write'] }]
      parameter Swagger::Schema::SLUG
      parameter name: 'id', in: :path, schema: { type: :string, format: :uuid }, description: 'id'
      parameter name: :body, in: :body, schema: {
        type: :object,
        properties: Swagger::Schema::TASK
      }

      let(:body) do
        {
          task: { title: 'Buy red roses' }
        }
      end

      response_empty200
      response400
      response404
      regular_api_responses
    end

    delete('delete task') do
      tags 'Tasks'
      produces 'application/json'
      security [{ oauth2: ['tasks', 'tasks:write'] }]
      parameter Swagger::Schema::SLUG
      parameter Swagger::Schema::ID
      response_empty200
      response404
      regular_api_responses
    end
  end
end
