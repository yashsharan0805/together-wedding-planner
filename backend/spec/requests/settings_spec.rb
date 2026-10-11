# Copyright (C) 2024-2025 LibreWeddingPlanner contributors

# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'settings' do
  include_context 'when API request is authenticated'

  path '/{slug}/settings' do
    get('show settings') do
      let(:'ids[]') { SettingsController::ALLOWED_SETTINGS } # rubocop:disable RSpec/VariableName
      tags 'Settings'
      produces 'application/json'
      security [{ oauth2: ['settings'] }]
      parameter Swagger::Schema::SLUG
      parameter name: 'ids[]',
                in: :query,
                schema: {
                  type: :array,
                  items: { type: :string, enum: SettingsController::ALLOWED_SETTINGS }
                },
                style: :form,
                explode: true,
                required: true,
                description: <<~MD
                  Array of setting keys. Allowed values:

                  #{SettingsController::ALLOWED_SETTINGS.map { "- `#{it}`" }.join("\n")}
                MD
      response(200, 'successful') do
        schema type: :object,
               properties: {
                 date: { type: :string, format: :date, nullable: true },
                 bus_management: { type: :boolean, nullable: true },
                 display_menu_choices: { type: :boolean, nullable: true },
                 invitation_config: {
                   type: :object,
                   nullable: true,
                   properties: {
                     qr_position: {
                       type: :object,
                       properties: {
                         x: { type: :number, minimum: 0 },
                         y: { type: :number, minimum: 0 }
                       }
                     },
                     qr_size_px: { type: :number, minimum: 50 },
                     qr_color: { type: :string, pattern: '^#[a-fA-F0-9]{6}$' },
                     qr_fill_color: { type: :string, pattern: '^#[a-fA-F0-9]{6}$', nullable: true },
                     text_position: {
                       type: :object,
                       properties: {
                         x: { type: :number, minimum: 0 },
                         y: { type: :number, minimum: 0 }
                       }
                     },
                     text_font_family: { type: :string, enum: FONTS_AVAILABLE },
                     text_color: { type: :string, pattern: '^#[a-fA-F0-9]{6}$' },
                     text_font_size: { type: :number, minimum: 0 },
                     text_font_weight: { type: :number, minimum: 100, maximum: 900 },
                     text_align: { type: :string, enum: InvitationConfig::ALIGNMENTS_ALLOWED },
                     fonts_available: { type: :array,
                                        items: { type: :string, enum: FONTS_AVAILABLE } },
                     background: {
                       type: :object,
                       properties: {
                         url: { type: :string },
                         metadata: {}
                       }
                     }
                   }
                 }
               }

        run_test!
      end
    end

    patch('update settings') do
      let(:body) do
        {
          settings: {
            date: (Time.zone.today + 60.days).to_s
          }
        }
      end
      tags 'Settings'
      consumes 'application/json'
      produces 'application/json'
      security [{ oauth2: ['settings', 'settings:write'] }]
      parameter Swagger::Schema::SLUG
      parameter name: :body, in: :body, schema: {
        type: :object,
        required: %w[settings],
        properties: {
          settings: {
            type: :object,
            properties: {
              date: { type: :string, format: :date }
            }
          }
        }
      }

      response_empty200
      response400
      regular_api_responses
    end
  end

  path '/{slug}/settings/fonts' do
    get('List fonts available') do
      security [{ oauth2: ['settings'] }]
      response(200, 'successful') do
        schema type: :object,
               required: [:fonts],
               properties: {
                 fonts: {
                   type: :array,
                   items: :string
                 }
               }
      end
    end
  end

  path '/{slug}/settings/request_wedding_deletion' do
    post('Request the wedding to be deleted') do
      tags 'Settings'
      consumes 'application/json'
      produces 'application/json'
      security [{ oauth2: ['settings', 'settings:write'] }]
      parameter Swagger::Schema::SLUG

      response_empty200 do
        wedding.reload

        expect(wedding.deletion_token).not_to be_nil
        expect(wedding.deletion_token_expires_at).not_to be_nil
      end
    end
  end

  path '/{slug}/settings/confirm_wedding_deletion' do
    get('Confirm the deletion of the wedding') do
      tags 'Settings'
      parameter Swagger::Schema::SLUG
      parameter name: :deletion_token, in: :query, type: :string

      before { wedding.generate_deletion_token! }

      response(302, 'Redirection to the success page') do
        let(:deletion_token) { wedding.deletion_token }

        run_test! do
          expect { wedding.reload }.to raise_error(ActiveRecord::RecordNotFound)
          expect(response.location).to eq('http://www.example.com/system/successful-website-deletion')
        end
      end

      response(302, 'Redirection to the incorrect/expired token page (incorrect token)') do
        let(:deletion_token) { 'invented-token' }

        run_test! do
          expect(wedding.reload).to be_present
          expect(response.location).to eq('http://www.example.com/system/unsuccessful-website-deletion')
        end
      end

      response(302, 'Redirection to the incorrect/expired token page (null token)') do
        let(:deletion_token) { nil }

        run_test! do
          expect(wedding.reload).to be_present
          expect(response.location).to eq('http://www.example.com/system/unsuccessful-website-deletion')
        end
      end

      response(302, 'Redirection to the incorrect/expired token page (expired token)') do
        let(:deletion_token) { wedding.deletion_token }
        before { wedding.update!(deletion_token_expires_at: 1.minute.ago) }

        run_test! do
          expect(wedding.reload).to be_present
          expect(response.location).to eq('http://www.example.com/system/unsuccessful-website-deletion')
        end
      end
    end
  end
end
