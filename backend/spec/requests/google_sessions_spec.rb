# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Google sign-in', type: :request do
  let(:wedding) { create(:wedding) }
  around { |example| ActsAsTenant.with_tenant(wedding) { example.run } }
  let(:user) { create(:user, wedding:, email: 'planner@gmail.com') }
  let(:claims) { { 'sub' => 'google-account-123', 'email' => user.email, 'email_verified' => true } }

  before { allow(ENV).to receive(:[]).and_call_original; allow(ENV).to receive(:[]).with('GOOGLE_CLIENT_ID').and_return('test-client') }

  def authenticate(payload = claims)
    get '/google/config', as: :json
    nonce = response.parsed_body['nonce']
    allow(Google::Auth::IDTokens).to receive(:verify_oidc).with('test-token', aud: 'test-client').and_return(payload.merge('nonce' => nonce))
    post '/google/sign_in', params: { credential: 'test-token', slug: wedding.slug }, as: :json
  end

  it 'signs a confirmed member in and binds their stable Google subject' do
    user
    authenticate
    expect(response).to have_http_status(:created)
    expect(user.reload.google_subject).to eq('google-account-123')
    get "/#{wedding.slug}/planner", as: :json
    expect(response).to have_http_status(:ok)
  end

  it 'does not grant membership to a Google user merely because they know the slug' do
    other_wedding = create(:wedding)
    other_user = ActsAsTenant.with_tenant(other_wedding) do
      create(:user, wedding: other_wedding, email: 'outsider@gmail.com')
    end
    expect(Membership.exists?(user: other_user)).to be(false)
    authenticate(claims.merge('email' => other_user.email))
    expect(response).to have_http_status(:forbidden)
  end

  it 'creates a new wedding and confirmed membership for a verified Google account' do
    allow(ENV).to receive(:[]).with('TOGETHER_HOSTED').and_return('true')
    get '/google/config', as: :json
    payload = {
      'sub' => 'new-google-account', 'email' => 'new-planner@gmail.com', 'email_verified' => true,
      'nonce' => response.parsed_body['nonce']
    }
    allow(Google::Auth::IDTokens).to receive(:verify_oidc).and_return(payload)
    post '/google/sign_in', params: { credential: 'test-token', slug: 'new-google-wedding', create_wedding: true }, as: :json
    expect(response).to have_http_status(:created)
    created_wedding = Wedding.find_by!(slug: 'new-google-wedding')
    ActsAsTenant.with_tenant(created_wedding) do
      expect(Membership.find_by!(user: User.find_by!(email: payload['email'])).confirmed_at).to be_present
      expect(created_wedding.settings).to be_present
      expect(created_wedding.settings.invitation_config).to be_nil
    end
    get '/new-google-wedding/planner', as: :json
    expect(response).to have_http_status(:ok)
  end

  it 'rejects an unverified email' do
    authenticate(claims.merge('email_verified' => false))
    expect(response).to have_http_status(:unauthorized)
  end

  it 'explains a missing account and allows creation after a fresh Google challenge' do
    payload = claims.merge('sub' => 'retry-google-account', 'email' => 'retry-planner@gmail.com')
    authenticate(payload)
    expect(response).to have_http_status(:not_found)
    expect(response.parsed_body['message']).to include('Create a new wedding with Google')

    get '/google/config', as: :json
    allow(Google::Auth::IDTokens).to receive(:verify_oidc).and_return(payload.merge('nonce' => response.parsed_body['nonce']))
    post '/google/sign_in', params: { credential: 'test-token', slug: 'retry-wedding', create_wedding: true }, as: :json
    expect(response).to have_http_status(:created)
    get '/retry-wedding/planner', as: :json
    expect(response).to have_http_status(:ok)
  end

  it 'rejects third-party email linking without Google Workspace authority' do
    authenticate(claims.merge('email' => 'person@example.com'))
    expect(response).to have_http_status(:unauthorized)
  end

  it 'rejects a nonce that was not issued to this browser session' do
    allow(Google::Auth::IDTokens).to receive(:verify_oidc).and_return(claims.merge('nonce' => 'wrong'))
    post '/google/sign_in', params: { credential: 'test-token', slug: wedding.slug }, as: :json
    expect(response).to have_http_status(:unauthorized)
  end

  it 'rejects invalid signatures, expiry and audience verification errors' do
    allow(Google::Auth::IDTokens).to receive(:verify_oidc).and_raise(Google::Auth::IDTokens::VerificationError)
    post '/google/sign_in', params: { credential: 'invalid', slug: wedding.slug }, as: :json
    expect(response).to have_http_status(:unauthorized)
  end

  context 'with Google invitations on the hosted planner' do
    before { allow(ENV).to receive(:[]).with('TOGETHER_GOOGLE_INVITES').and_return('true') }

    def invite(email)
      sign_in user
      post "/#{wedding.slug}/memberships", params: { user: { email: } }, as: :json
      expect(response).to have_http_status(:created)
      sign_out user
      User.find_by!(email: email.strip.downcase)
    end

    it 'joins an invited identity without email delivery or access from a copied link alone' do
      deliveries = ActionMailer::Base.deliveries.size
      invited = invite(' Invited@gmail.com ')
      expect(ActionMailer::Base.deliveries.size).to eq(deliveries)
      expect(invited).not_to be_confirmed
      membership = Membership.find_by!(user: invited)
      expect(membership.confirmed_at).to be_nil
      # Google is a fresh proof of email ownership even when the unrelated
      # three-day email confirmation window has ended.
      invited.update!(confirmation_sent_at: 4.days.ago)
      get "/#{wedding.slug}/planner", as: :json
      expect(response).to have_http_status(:unauthorized)

      authenticate(claims.merge('email' => invited.email, 'sub' => 'invited-google-subject'))
      expect(response).to have_http_status(:created)
      expect(invited.reload).to be_confirmed
      expect(membership.reload.confirmed_at).to be_present
      expect(membership.confirmation_token).to be_nil
      get "/#{wedding.slug}/planner", as: :json
      expect(response).to have_http_status(:ok)
    end

    it 'does not accept an expired invitation' do
      invited = invite('expired@gmail.com')
      membership = Membership.find_by!(user: invited)
      membership.update!(confirmation_token_expires_at: 1.minute.ago)
      authenticate(claims.merge('email' => invited.email, 'sub' => 'expired-google-subject'))
      expect(response).to have_http_status(:forbidden)
      expect(invited.reload).not_to be_confirmed
      expect(membership.reload.confirmed_at).to be_nil
    end

    it 'does not unlock an invited account' do
      invited = invite('locked@gmail.com')
      invited.update!(locked_at: Time.current)
      authenticate(claims.merge('email' => invited.email, 'sub' => 'locked-google-subject'))
      expect(response).to have_http_status(:forbidden)
      expect(Membership.find_by!(user: invited).confirmed_at).to be_nil
    end
  end
end
