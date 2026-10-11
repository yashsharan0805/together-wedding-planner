# frozen_string_literal: true

RSpec.shared_context 'when API request is authenticated' do
  let(:wedding) { create(:wedding) }
  let(:user) { create(:user, wedding:, password: 'supersecretpassword', password_confirmation: 'supersecretpassword') }
  let(:slug) { wedding.slug }
  let(:Authorization) do # rubocop:disable RSpec/VariableName
    application = user.applications.create!(
      name: 'My client',
      redirect_uri: 'urn:ietf:wg:oauth:2.0:oob',
      scopes: Doorkeeper.configuration.scopes.map(&:to_s)
    )
    token = Doorkeeper::AccessToken.find_or_create_for(
      application:,
      resource_owner: user,
      scopes: Doorkeeper.configuration.scopes
    )
    "Bearer #{token.plaintext_token}"
  end

  around do |example|
    ActsAsTenant.with_tenant(wedding) do
      example.run
    end
  end

  before do
    sign_in(user)
  end
end

RSpec.shared_context 'when API request is authenticated with system credentials' do
  let(:wedding) { create(:wedding) }
  let(:user) { create(:user, wedding:, password: 'supersecretpassword', password_confirmation: 'supersecretpassword') }

  let(:Authorization) do # rubocop:disable RSpec/VariableName
    application = user.applications.create!(
      name: 'System client',
      redirect_uri: 'urn:ietf:wg:oauth:2.0:oob',
      scopes: ['system']
    )
    token = Doorkeeper::AccessToken.find_or_create_for(
      application:,
      resource_owner: user,
      scopes: Doorkeeper.configuration.scopes
    )
    "Bearer #{token.plaintext_token}"
  end
end
