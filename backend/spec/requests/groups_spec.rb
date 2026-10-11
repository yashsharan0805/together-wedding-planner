# Copyright (C) 2024-2025 LibreWeddingPlanner contributors

# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'groups' do
  include_context 'when API request is authenticated'

  before do
    create_list(:group, 2, wedding:)
  end

  path '/{slug}/groups' do
    get('list groups') do
      tags 'Groups'
      produces 'application/json'
      security [{ oauth2: ['guests'] }]
      parameter Swagger::Schema::SLUG
      response(200, 'successful') do
        schema type: :array,
               items: {
                 type: :object,
                 required: %i[id name icon parent_id color attendance],
                 properties: {
                   id: { type: :string, format: :uuid },
                   name: { type: :string },
                   icon: { type: :string, example: 'pi pi-crown', nullable: true,
                           description: 'The CSS classes used by the icon' },
                   parent_id: { type: :string, format: :uuid, nullable: true },
                   color: { type: :string, pattern: '^#(?:[0-9a-fA-F]{3}){1,2}$' },
                   attendance: {
                     type: :object,
                     required: %i[total considered invited confirmed declined tentative],
                     properties: {
                       total: { type: :integer, minimum: 0, description: 'Total number of guests in any status' },
                       considered: { type: :integer, minimum: 0 },
                       invited: { type: :integer, minimum: 0 },
                       confirmed: { type: :integer, minimum: 0 },
                       declined: { type: :integer, minimum: 0 },
                       tentative: { type: :integer, minimum: 0 }
                     }
                   }
                 }
               }
        run_test!
      end
      regular_api_responses
    end

    post('create group') do
      tags 'Groups'
      consumes 'application/json'
      produces 'application/json'
      security [{ oauth2: ['guests', 'guests:write'] }]
      parameter Swagger::Schema::SLUG
      parameter name: :body, in: :body, schema: {
        type: :object,
        required: %i[group],
        properties: {
          group: {
            type: :object,
            required: %i[name],
            properties: Swagger::Schema::GROUP
          }
        }
      }
      response(201, 'created') do
        schema type: :object, properties: {
          id: { type: :string, format: :uuid },
          **Swagger::Schema::GROUP
        }

        let(:body) do
          {
            group: {
              name: 'New Group',
              icon: 'pi pi-heart',
              color: '#00ff00'
            }
          }
        end

        run_test!
      end
      regular_api_responses
    end

    path '/{slug}/groups/{id}' do
      let(:id) { Group.first.id }
      put('update group') do
        tags 'Groups'
        consumes 'application/json'
        produces 'application/json'
        security [{ oauth2: ['guests', 'guests:write'] }]
        parameter Swagger::Schema::SLUG
        parameter name: :id, in: :path, schema: { type: :string, format: :uuid }
        parameter name: :body, in: :body, schema: {
          type: :object,
          required: %i[group],
          properties: {
            group: {
              type: :object,
              required: %i[name],
              properties: Swagger::Schema::GROUP
            }
          }
        }
        response(200, 'updated') do
          schema type: :object, properties: {
            id: { type: :string, format: :uuid },
            **Swagger::Schema::GROUP
          }

          let(:body) do
            {
              group: {
                name: 'Updated Group Name',
                icon: 'pi pi-star',
                color: '#ff5733'
              }
            }
          end

          run_test!
        end
        regular_api_responses
      end

      delete('delete group') do
        tags 'Groups'
        produces 'application/json'
        security [{ oauth2: ['guests', 'guests:write'] }]
        parameter Swagger::Schema::SLUG
        parameter name: :id, in: :path, schema: { type: :string, format: :uuid }

        response_empty200
        regular_api_responses
      end
    end
  end
end
