# Copyright (C) 2024-2025 LibreWeddingPlanner contributors

# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'invitations' do
  include_context 'when API request is authenticated'

  let!(:invitations) { create_list(:invitation, 2, wedding:) }
  let!(:guests) { create_list(:guest, 3, wedding:, invitation: invitations.first) }
  let(:another_guest) { create(:guest, wedding:, invitation: nil) }

  before do
    wedding.settings.update!(bus_management: true)
    allow(ActsAsTenant).to receive(:current_tenant).and_return(wedding)
    allow(wedding).to receive(:needs_optimization!)
  end

  path '/{slug}/invitations' do
    get('list invitations') do
      tags 'Invitations'
      produces 'application/json'
      security [{ oauth2: ['guests'] }]
      parameter Swagger::Schema::SLUG

      response(200, 'successful') do
        schema type: :array,
               items: {
                 type: :object,
                 required: %i[id url guests],
                 properties: {
                   id: { type: :string, format: :uuid },
                   name: { type: :string, nullable: true },
                   url: { type: :string, format: :uri },
                   guests: {
                     type: :array,
                     items: {
                       type: :object,
                       required: %i[id name],
                       properties: {
                         id: { type: :string, format: :uuid },
                         name: { type: :string }
                       }
                     }
                   }
                 }
               }

        run_test!
      end
      regular_api_responses
    end

    post('create invitation') do
      tags 'Invitations'
      produces 'application/json'
      security [{ oauth2: ['guests', 'guests:write'] }]
      parameter Swagger::Schema::SLUG

      response(201, 'successful') do
        schema type: :object,
               required: %i[id],
               properties: {
                 id: { type: :string, format: :uuid }
               }

        run_test!
      end
      regular_api_responses
    end
  end

  path '/{slug}/invitations/email' do
    post('send invitations email') do
      tags 'Invitations'
      produces 'application/json'
      security [{ oauth2: ['guests'] }]
      parameter Swagger::Schema::SLUG

      response(200, 'successful') do
        run_test!
      end
      regular_api_responses
    end
  end

  path '/{slug}/invitations/{id}' do
    let(:id) { invitations.first.id }

    get('show invitation') do
      tags 'Invitations'
      produces 'application/json'
      security [{ oauth2: ['guests'] }]
      parameter Swagger::Schema::SLUG
      parameter Swagger::Schema::ID

      response(200, 'successful') do
        schema type: :object,
               required: %i[id guests],
               properties: {
                 id: { type: :string, format: :uuid },
                 guests: {
                   type: :array,
                   items: {
                     type: :object,
                     required: %i[id name],
                     properties: {
                       id: { type: :string, format: :uuid },
                       name: { type: :string },
                       status: { type: :string, enum: Guest.statuses.keys },
                       menu_choice: { type: :string, enum: Guest::DEFAULT_MENU_OPTIONS, nullable: true },
                       menu_restrictions: { type: :string, nullable: true },
                       needs_bus: { type: :boolean },
                       special_requests: { type: :string, nullable: true }
                     }
                   }
                 }
               }

        run_test!
      end
      response404
      # NOTE: show endpoint doesn't require authentication as it's used in the public RSVP form
    end

    patch('update invitation') do
      tags 'Invitations'
      consumes 'application/json'
      produces 'application/json'
      security [{ oauth2: ['guests', 'guests:write'] }]
      parameter Swagger::Schema::SLUG
      parameter Swagger::Schema::ID
      parameter name: :body, in: :body, schema: {
        type: :object,
        required: %i[invitation],
        properties: {
          invitation: {
            type: :object,
            required: %i[guest_ids],
            properties: {
              guest_ids: {
                type: :array,
                items: { type: :string, format: :uuid }
              }
            }
          }
        }
      }

      let(:body) do
        {
          invitation: {
            name: 'Belghouch family',
            guest_ids: [guests.third.id, guests.first.id, guests.second.id, another_guest.id]
          }
        }
      end

      response(200, 'successful') do
        schema type: :object,
               required: %i[id guests],
               properties: {
                 id: { type: :string, format: :uuid },
                 guests: {
                   type: :array,
                   items: {
                     type: :object,
                     required: %i[id name],
                     properties: {
                       id: { type: :string, format: :uuid },
                       name: { type: :string }
                     }
                   }
                 }
               }

        run_test! do
          invitation = Invitation.first
          expect(invitation.guest_ids).to contain_exactly(
            guests.first.id,
            guests.second.id,
            guests.third.id,
            another_guest.id
          )
          # Preserve order of ids sent via API
          expect(guests.third.reload.invitation_order).to eq(0)  # Reordered
          expect(guests.first.reload.invitation_order).to eq(1)  # Reordered
          expect(guests.second.reload.invitation_order).to eq(2) # Reordered
          expect(another_guest.reload.invitation_order).to eq(3) # Added
          expect(invitation.name).to eq 'Belghouch family'

          expect(wedding).to have_received(:needs_optimization!)
        end
      end
      response404
      regular_api_responses
    end

    delete('delete invitation') do
      tags 'Invitations'
      produces 'application/json'
      security [{ oauth2: ['guests', 'guests:write'] }]
      parameter Swagger::Schema::SLUG
      parameter Swagger::Schema::ID

      response(204, 'No Content') do
        run_test! do
          expect(wedding).to have_received(:needs_optimization!)
        end
      end
      response404
      regular_api_responses
    end
  end
end
