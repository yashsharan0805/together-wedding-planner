# Copyright (C) 2024-2025 LibreWeddingPlanner contributors

# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'users' do
  include_context 'when API request is authenticated'

  path '/{slug}/memberships' do
    get('list memberships and their statuses') do
      tags 'Users'
      produces 'application/json'
      security [{ oauth2: ['users'] }]
      parameter Swagger::Schema::SLUG

      before do
        create_list(:user, 3, wedding:)
      end

      response(200, 'list of memberships') do
        schema type: :array, items: {
          type: :object,
          required: %i[id user_email status deletable],
          properties: {
            id: { type: :string, format: :uuid },
            user_email: { type: :string, format: :email },
            status: { type: :string, enum: %i[expired pending active] },
            deletable: { type: :boolean }
          }
        }
        run_test! do
          expect(response.parsed_body.count).to eq(4) # 3 created + default caller
          expect(response.parsed_body.count { it['deletable'] }).to eq(3)
          expect(response.parsed_body.find { it['id'] == user.memberships.sole.id }['deletable']).to be(false)
        end
      end

      regular_api_responses
    end

    post('add a user to a wedding') do
      tags 'Users'
      consumes 'application/json'
      produces 'application/json'
      security [{ oauth2: ['users', 'users:write'] }]
      parameter Swagger::Schema::SLUG
      parameter name: :body, in: :body, schema: {
        type: :object,
        required: [:user],
        properties: {
          user: {
            type: :object,
            required: [:email],
            properties: {
              email: { type: :string, format: :email }
            }
          }
        }
      }

      let(:body) do
        {
          user: {
            email: 'foo@bar.com'
          }
        }
      end

      response(201, 'created') do
        before do
          allow(CreateMembershipUseCase).to receive(:new).with(email: 'foo@bar.com').and_return(
            instance_double(CreateMembershipUseCase, call: true)
          )
        end

        schema type: :object
        run_test!
      end

      response(400, 'user is already a member') do
        before do
          allow(CreateMembershipUseCase).to receive(:new).with(email: 'foo@bar.com').and_return(
            instance_double(CreateMembershipUseCase, call: false, errors: ['User is already a member'])
          )
        end

        schema '$ref' => '#/components/schemas/error'
        run_test!
      end
      regular_api_responses
    end
  end

  path '/{slug}/memberships/{id}' do
    let(:membership) { Membership.find_by!(user: create(:user, wedding:), wedding:) }
    let(:id) { membership.id }

    delete('delete a membership') do
      tags 'Users'
      security [{ oauth2: ['users', 'users:write'] }]
      parameter Swagger::Schema::SLUG
      parameter name: :id, in: :path, schema: { type: :string, format: :uuid }

      response(200, 'deleted') do
        run_test! do
          expect(Membership.find_by(id:)).to be_nil
        end
      end

      response(403, 'cannot remove yourself from a wedding') do
        let(:membership) { Membership.find_by(user:, wedding:) } # The one making the request
        schema '$ref' => '#/components/schemas/error'
        run_test! do
          expect(Membership.find_by(id:)).to be_present
        end
      end
    end
  end

  path '/{slug}/memberships/{id}/accept' do
    let(:membership) { Membership.find_by!(user: create(:user, wedding:), wedding:) }
    let(:id) { membership.id }

    before do
      membership.update!(
        confirmation_token: SecureRandom.alphanumeric(60),
        confirmation_token_expires_at: 1.week.from_now,
        confirmed_at: nil
      )
    end

    get('accept a membership invitation') do
      # TODO: Ensure this works without being authenticated
      tags 'Users'
      parameter Swagger::Schema::SLUG
      parameter name: :id, in: :path, schema: { type: :string, format: :uuid }
      parameter name: :confirmation_token, in: :query, type: :string

      response(302, 'success') do
        let(:confirmation_token) { membership.confirmation_token }
        run_test! do
          membership.reload

          expect(membership.confirmation_token).to be_nil
          expect(membership.confirmation_token_expires_at).to be_nil
          expect(membership.confirmed_at).to be_within(1.second).of(Time.zone.now)

          expect(response.headers['location']).to eq("http://www.example.com/#{wedding.slug}")
        end
      end

      response(302, 'invalid/expired token') do
        let(:confirmation_token) { 'invalid-token' }
        run_test! do
          membership.reload

          expect(membership.confirmation_token_expires_at).to be_future
          expect(membership.confirmed_at).to be_nil

          expect(response.headers['location']).to eq('http://www.example.com/system/unsuccessful-membership-confirmation')
        end
      end
    end
  end
end
