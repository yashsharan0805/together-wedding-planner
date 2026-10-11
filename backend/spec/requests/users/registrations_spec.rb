# Copyright (C) 2024-2025 LibreWeddingPlanner contributors

# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'users/registrations' do
  path '/{slug}/users' do
    let(:slug) { 'foo' }

    post('create registration') do
      tags 'Users Registrations'
      consumes 'application/json'
      produces 'application/json'

      parameter Swagger::Schema::SLUG
      parameter name: :body, in: :body, schema: {
        type: :object,
        required: %i[user captcha],
        properties: {
          user: {
            type: :object,
            required: %i[email password password_confirmation],
            properties: {
              email: { type: :string, format: :email },
              password: SwaggerResponseHelper::PASSWORD,
              password_confirmation: SwaggerResponseHelper::PASSWORD
            }
          },
          **Swagger::Schema::CAPTCHA
        }
      }

      before do
        allow(LibreCaptcha).to receive(:new).and_return(instance_double(LibreCaptcha, valid?: true))
      end

      let(:body) do
        {
          user: {
            email: 'foo@example.com',
            password: 'sup3rs3cr3tp455w0rd',
            password_confirmation: 'sup3rs3cr3tp455w0rd'
          },
          captcha: {
            id: SecureRandom.uuid,
            answer: 'foobar'
          }
        }
      end

      response(201, 'created') do
        schema '$ref' => '#/components/schemas/user'

        run_test! do
          user = User.find_by!(email: 'foo@example.com')
          expect(user.weddings.map(&:slug)).to eq(['foo'])

          membership = Membership.find_by!(user:, wedding: Wedding.find_by(slug: :foo))
          expect(membership.confirmed_at).to be_within(1.second).of(Time.zone.now)
        end
      end

      response(422, 'failed captcha') do
        before do
          allow(LibreCaptcha).to receive(:new).and_return(instance_double(LibreCaptcha, valid?: false))
        end

        schema type: :object,
               properties: {
                 error: { type: :string }
               }

        run_test! do
          expect(User.exists?(email: 'foo@example.com')).to be(false)
          expect(Wedding.exists?(slug: 'foo')).to be(false)
        end
      end

      response(422, 'wedding already exists') do
        before do
          Wedding.create!(slug:)
        end

        schema '$ref' => '#/components/schemas/error'

        run_test! do
          expect(User.exists?(email: 'foo@example.com')).to be(false)
          expect(Wedding.exists?(slug: 'foo')).to be(true)
        end
      end

      response(422, 'user already exists') do
        before do
          create(:user, email: 'foo@example.com', wedding: create(:wedding))
        end

        schema '$ref' => '#/components/schemas/error'

        run_test! do
          expect(User.exists?(email: 'foo@example.com')).to be(true)
          expect(Wedding.exists?(slug: 'foo')).to be(false)
        end
      end
    end
  end
end
