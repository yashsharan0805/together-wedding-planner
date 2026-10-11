# Copyright (C) 2024-2025 LibreWeddingPlanner contributors

# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'website' do
  include_context 'when API request is authenticated'

  before do
    wedding.website.update!(
      content: '# Welcome',
      version: 'v1.0',
      domain: 'foo.com',
      pages: [
        build(:page, slug: '', title: 'Home', content: "# We're getting married!", subtitle: Date.tomorrow.to_s),
        build(:page, slug: 'transport', title: 'Transport', content: 'Here is how to get to the venue: (...)')
      ]
    )
  end

  path '/{slug}/website' do
    get('get website') do
      tags 'Website'
      produces 'application/json'
      security [{ oauth2: ['website'] }]
      parameter Swagger::Schema::SLUG

      response(200, 'successful') do
        schema type: :object,
               required: [:version],
               properties: {
                 content: { type: :string, description: 'Markdown content' },
                 domain: { type: :string, description: 'Domain name' },
                 version: { type: :string },
                 pages: {
                   type: :array,
                   items: {
                     type: :object,
                     required: %i[slug title content],
                     properties: {
                       slug: { type: :string },
                       title: { type: :string },
                       title_font_family: { type: :string },
                       subtitle: { type: :string, nullable: true },
                       content: { type: :string }
                     }
                   }
                 }
               }

        run_test!
      end
    end

    patch 'update website' do
      tags 'Website'
      consumes 'application/json'
      produces 'application/json'
      security [{ oauth2: ['website', 'website:write'] }]
      parameter Swagger::Schema::SLUG
      parameter name: :body, in: :body, schema: {
        type: :object,
        required: %i[website],
        properties: {
          website: {
            type: :object,
            required: %i[content],
            properties: {
              content: { type: :string, description: 'Markdown content' },
              domain: { type: :string, description: 'Domain name' },
              pages: {
                type: :array,
                items: {
                  type: :object,
                  required: %i[slug title content],
                  properties: {
                    slug: { type: :string },
                    title: { type: :string },
                    title_font_family: { type: :string },
                    subtitle: { type: :string, nullable: true },
                    content: { type: :string }
                  }
                }
              }
            }
          }
        }
      }

      let(:updated_pages) do
        [
          { slug: '', title: 'Home', content: nil, subtitle: nil, title_font_family: 'Arial' },
          { slug: 'food', title: 'Banquet', content: 'Here is the menu:', subtitle: 'enjoy!',
            title_font_family: 'Arial' },
          { slug: 'venue', title: 'Venue', content: 'This is what the venue looks like',
            title_font_family: 'Cinzel', subtitle: nil }
        ]
      end

      let(:body) do
        {
          website: {
            content: '# Updated Content',
            version: 'v2.0',
            domain: 'wedding.example.com',
            pages: updated_pages
          }
        }
      end

      response(200, 'successful') do
        schema type: :object

        run_test! do
          website = ActsAsTenant.current_tenant.website.reload

          expect(website.content).to eq('# Updated Content')
          expect(website.domain).to eq('wedding.example.com')
          expect(website.version).to eq('v2.0')
          expect(website.pages.map(&:attributes)).to eq(
            updated_pages
          )
        end
      end

      regular_api_responses
    end
  end

  path '/{slug}/website/validate_dns' do
    get('get website') do
      tags 'Website'
      produces 'application/json'
      security [{ oauth2: %w[website website] }]
      parameter Swagger::Schema::SLUG

      response(200, 'incorrect configuration') do
        schema type: :object,
               properties: {
                 message: { type: :string },
                 errors: { type: :array, items: { type: :string } }
               }

        run_test!
      end

      regular_api_responses
    end
  end
end
