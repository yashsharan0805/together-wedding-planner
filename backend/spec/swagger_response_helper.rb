# Copyright (C) 2024-2025 LibreWeddingPlanner contributors

# frozen_string_literal: true

module SwaggerResponseHelper
  TIMESTAMP_FORMAT = '\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{3}Z'
  TIMESTAMP_EXAMPLE = Time.zone.now.iso8601(3)

  TIMESTAMP = { type: :string, pattern: TIMESTAMP_FORMAT, example: TIMESTAMP_EXAMPLE }.freeze
  PASSWORD = { type: :string, minLength: User.password_length.begin, maxLength: User.password_length.end }.freeze

  def regular_api_responses
    response401
  end

  def response400
    response(400, 'Validation errors in input parameters') do
      produces 'application/json'
      schema '$ref' => '#/components/schemas/error'
      let(:body) { {} } # Invalid body to trigger validation errors
      run_test!
    end
  end

  def response_empty200(&)
    response(200, 'Success') do
      produces 'application/json'
      schema type: :object
      run_test!(&)
    end
  end

  def response_empty201(&)
    response(201, 'Created') do
      produces 'application/json'
      schema type: :object
      run_test!(&)
    end
  end

  def response404
    response(404, 'Record not found') do
      produces 'application/json'
      schema '$ref' => '#/components/schemas/error'
      let(:id) { '00000000-0000-0000-0000-000000000000' } # Non-existing UUID
      run_test!
    end
  end

  def response401(message: nil)
    response(401, 'Unauthorized') do
      produces 'application/json'
      schema type: :object,
             required: %i[error],
             properties: {
               error: { type: :string, example: message || 'You need to sign in or sign up before continuing.' }
             }

      before do
        sign_out(user)
      end

      let(:Authorization) { nil } # 401 only happens on cookie-based sessions
      run_test!
    end
  end
end
