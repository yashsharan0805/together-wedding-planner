# frozen_string_literal: true

application = Doorkeeper::Application.create(
  name: 'My client',
  redirect_uri: 'urn:ietf:wg:oauth:2.0:oob',
  scopes: Doorkeeper.configuration.scopes.map(&:to_s), # All scopes defined
  owner: User.first
)
puts "     OAuth client: #{application.uid}"
puts "     Oauth secret: #{application.plaintext_secret}"
