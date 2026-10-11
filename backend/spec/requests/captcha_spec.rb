# Copyright (C) 2024-2025 LibreWeddingPlanner contributors

# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'captcha' do
  path '/captcha' do
    post('create a CAPTCHA challenge') do
      tags 'CAPTCHA'
      consumes 'application/json'
      produces 'application/json'

      before do
        allow(LibreCaptcha).to receive(:new).and_return(instance_double(LibreCaptcha, id: 'captcha-id-123'))
      end

      response(201, 'created') do
        schema type: :object,
               required: %i[id],
               properties: {
                 id: { type: :string, format: :uuid },
                 media_url: { type: :string, format: :uri }
               }
        run_test!
      end

      response(204, 'captcha feature is disabled') do
        before { allow(ENV).to receive(:[]).with('DISABLE_CAPTCHA').and_return('true') }

        run_test!
      end
    end
  end
end
