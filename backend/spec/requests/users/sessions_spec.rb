# Copyright (C) 2024-2025 LibreWeddingPlanner contributors

# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'users/sessions' do
  include_context 'when API request is authenticated'

  path '/{slug}/users/sign_in' do
    before do
      sign_out(user)
    end

    post('create session') do
      tags 'Users Sessions'
      consumes 'application/json'
      produces 'application/json'

      parameter Swagger::Schema::SLUG
      parameter name: :body, in: :body, schema: {
        type: :object,
        required: %i[user],
        properties: {
          user: {
            type: :object,
            required: %i[email password],
            properties: {
              email: { type: :string, format: :email },
              password: SwaggerResponseHelper::PASSWORD
            }
          }
        }
      }

      response(201, 'created') do
        schema '$ref' => '#/components/schemas/user'
        let(:body) do
          {
            user: {
              email: user.email,
              password: 'supersecretpassword'
            }
          }
        end

        run_test! do
          expect(user.reload.last_sign_in_at).to be_within(1.second).of(Time.zone.now)
        end
      end

      response401(message: 'Invalid Email or password.')
    end
  end

  path '/{slug}/users/sign_out' do
    parameter Swagger::Schema::SLUG
    delete('delete session') do
      tags 'Users Sessions'
      consumes 'application/json'
      produces 'application/json'
      response(204, 'Session destroyed') do
        run_test!
      end
    end
  end
end
