# frozen_string_literal: true

require 'rails_helper'
require 'swagger_helper'

RSpec.describe 'API documentation' do
  it 'documents all oauth scopes' do
    scopes_documented = RSpec.configuration.openapi_specs.dig('v1/swagger.yaml', :components, :securitySchemes, :oauth2,
                                                              :flows, :clientCredentials, :scopes).keys

    expect(Doorkeeper.configuration.scopes.map(&:to_s)).to match_array(scopes_documented)
  end
end
