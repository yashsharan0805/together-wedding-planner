# Copyright (C) 2024-2025 LibreWeddingPlanner contributors

# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'users/confirmations' do
  let(:new_wedding) { create(:wedding, slug: 'new-wedding') }
  let(:new_user) { create(:user, email: 'new@example.com', wedding: new_wedding) }
  let(:slug) { new_wedding.slug }

  around do |example|
    ActsAsTenant.with_tenant(new_wedding) do
      example.run
    end
  end

  before do
    new_user.update!(confirmed_at: nil)
    new_user.send_confirmation_instructions
  end

  path '/{slug}/users/confirmation' do
    get('confirm user email') do
      tags 'Users'

      parameter Swagger::Schema::SLUG
      parameter name: :confirmation_token, in: :query, type: :string

      response(302, 'confirmed') do
        let(:confirmation_token) { new_user.confirmation_token }
        run_test! do
          expect(response.headers['location']).to eq('http://www.example.com/new-wedding')
        end
      end

      response(422, 'invalid token') do
        schema '$ref' => '#/components/schemas/error'
        let(:confirmation_token) { 'invalid' }
        run_test!
      end

      context 'when the browser has an active session for another wedding' do
        before do
          ActsAsTenant.without_tenant do
            old_wedding = create(:wedding, slug: 'old-wedding')
            old_user = create(:user, email: 'old@example.com', wedding: old_wedding)

            sign_in(old_user)
          end
        end

        response(302, 'confirmed') do
          let(:confirmation_token) { new_user.confirmation_token }
          run_test! do
            expect(response.headers['location']).to eq('http://www.example.com/new-wedding')
          end
        end
      end
    end
  end
end
