# Copyright (C) 2024-2025 LibreWeddingPlanner contributors

# frozen_string_literal: true

require 'rails_helper'
require_relative 'swagger_response_helper'
require_relative 'requests/schemas'

include SwaggerResponseHelper # rubocop:disable Style/MixinUsage

RSpec.configure do |config|
  # Specify a root folder where Swagger JSON files are generated
  # NOTE: If you're using the rswag-api to serve API descriptions, you'll need
  # to ensure that it's configured to serve Swagger from the same folder
  config.openapi_root = Rails.root.join('swagger').to_s

  # Define one or more Swagger documents and provide global metadata for each one
  # When you run the 'rswag:specs:swaggerize' rake task, the complete Swagger will
  # be generated at the provided relative path under openapi_root
  # By default, the operations defined in spec files are added to the first
  # document below. You can override this behavior by adding a openapi_spec tag to the
  # the root example_group in your specs, e.g. describe '...', openapi_spec: 'v2/swagger.json'

  scopes = {
    guests: %w[guests groups affinities invitations],
    buses: 'buses',
    expenses: ['expenses', 'payments', 'cost centers'],
    settings: 'settings',
    simulations: ['table types', 'simulations'],
    tasks: 'tasks',
    website: 'website',
    users: 'users',
    engine: 'engine',
    locations: 'locations'
  }.transform_values { Array.wrap(it).join(', ') }
   .map do |scope, entities|
     {
       scope.to_s => "Provides read-only access to #{entities}.",
       "#{scope}:write" => "Provides write access to #{entities}."
     }
   end.inject(:merge).merge(
     'system' => 'Reserved for system operations'
   )
  config.openapi_specs = {
    'v1/swagger.yaml' => {
      openapi: '3.0.1',
      info: {
        title: 'API V1',
        version: 'v1'
      },
      paths: {},
      servers: [
        {
          url: 'http://www.example.com',
          description: 'Suitable for rspec tests'
        },
        {
          url: 'http://libre-wedding-planner.app.localhost/api',
          description: 'Suitable for development'
        }
      ],
      components: {
        schemas: {
          id: {
            type: :object,
            properties: {
              id: { type: :string, format: :uuid }
            }
          },
          capacity: {
            type: :object,
            properties: {
              min: { type: :integer, minimum: 0, example: 8 },
              max: { type: :integer, minimum: 0, example: 10 }
            }
          },
          task_solution: {
            type: :array,
            items: {
              type: :object,
              properties: {
                id: { type: :string, format: :uuid, description: 'The ID of the bundle (bus, table)' },
                capacity: { '$ref' => '#/components/schemas/capacity' },
                people_ids: {
                  type: :array,
                  items: { type: :string, format: :uuid }, example: (people_ids = 8.times.map { SecureRandom.uuid_v4 })
                },
                pinned_ids: { type: :array, items: { type: :string, format: :uuid }, example: people_ids.first(2) }
              }
            }
          },
          error: {
            type: :object,
            required: %i[message errors],
            properties: {
              message: { type: :string },
              errors: { oneOf: [
                { type: :array, items: { type: :string } },
                { type: :object, additionalProperties: { type: :array, items: { type: :string } } }
              ] }
            }
          },
          location: {
            type: :object,
            required: %i[place_id latitude longitude label display_name],
            properties: {
              place_id: { type: :integer },
              latitude: { type: :string, minimum: -90, maximum: 90 },
              longitude: { type: :string, minimum: -180, maximum: 180 },
              label: { type: :string },
              display_name: { type: :string }
            }
          },
          user: {
            type: :object,
            properties: {
              id: { type: :string, format: :uuid },
              email: { type: :string, format: :email },
              created_at: SwaggerResponseHelper::TIMESTAMP,
              updated_at: SwaggerResponseHelper::TIMESTAMP,
              superadmin: { type: :boolean },
              language: { type: :string, nullable: true, minLength: 2, maxLength: 2 }
            }
          }
        },
        securitySchemes: {
          oauth2: {
            type: :oauth2,
            flows: {
              clientCredentials: {
                tokenUrl: '/api/oauth/token',
                scopes:
              }
            }
          }
        }
      }
    }
  }

  # Specify the format of the output Swagger file when running 'rswag:specs:swaggerize'.
  # The openapi_specs configuration option has the filename including format in
  # the key, this may want to be changed to avoid putting yaml in json files.
  # Defaults to json. Accepts ':json' and ':yaml'.
  config.openapi_format = :yaml

  config.openapi_no_additional_properties = true
  config.openapi_all_properties_required = true
end
