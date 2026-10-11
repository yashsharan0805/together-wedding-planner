# frozen_string_literal: true

require 'googleauth/id_tokens'

class GoogleSessionsController < ApplicationController
  skip_before_action :set_tenant, :authenticate_user!, :validate_access_to_wedding!, :doorkeeper_authorize!

  def configuration
    session[:google_nonce] = SecureRandom.hex(32)
    response.headers['Cache-Control'] = 'no-store'
    render json: { client_id: ENV['GOOGLE_CLIENT_ID'], nonce: session[:google_nonce] }
  end

  def create
    client_id = ENV['GOOGLE_CLIENT_ID'].presence
    unless client_id
      render json: { message: 'Google sign-in is not configured.' }, status: :service_unavailable
      return
    end

    payload = Google::Auth::IDTokens.verify_oidc(params.require(:credential), aud: client_id)
    nonce = session.delete(:google_nonce)
    unless nonce.present? && payload['nonce'].is_a?(String) &&
           ActiveSupport::SecurityUtils.secure_compare(nonce, payload['nonce']) &&
           payload['email_verified'] == true && payload['sub'].present?
      head :unauthorized
      return
    end

    # A third-party email may have changed ownership since Google verified it.
    # Only Gmail or verified Workspace identities are eligible for email linking.
    email = payload['email'].to_s.downcase
    unless email.end_with?('@gmail.com') || payload['hd'].present?
      render json: { message: 'Use password login for this email address, or a Gmail / Google Workspace account.' }, status: :unauthorized
      return
    end

    user = nil
    wedding = nil
    User.transaction do
      user = User.find_by(google_subject: payload['sub']) || User.find_by(email:)
      creating = params[:create_wedding] == true
      if creating
        user ||= User.new(email:, password: SecureRandom.hex(40), google_subject: payload['sub'])
        user.skip_confirmation! if user.new_record?
        user.save! if user.new_record?
      end
      unless user
        render json: { message: 'No wedding account exists for this Google email. Select Create a new wedding with Google, or accept your invitation first.' }, status: :not_found
        return
      end

      user.lock!
      if user.google_subject.present? && user.google_subject != payload['sub']
        head :unauthorized
        return
      end
      membership = nil
      unless creating
        wedding = Wedding.find_by!(slug: params.require(:slug))
        membership = ActsAsTenant.with_tenant(wedding) { Membership.find_by(user:) }
        membership&.lock!
        google_invitation = ENV['TOGETHER_GOOGLE_INVITES'] == 'true' &&
                            membership&.confirmed_at.nil? &&
                            membership&.confirmation_token_expires_at&.future?
        confirmed_member = membership&.confirmed_at && membership.confirmed_at <= Time.current
        unless confirmed_member || google_invitation
          render json: { message: 'Ask a wedding team member to invite this Google email address first.' }, status: :forbidden
          return
        end
        # Only the verified owner of the invited Gmail / Workspace identity can
        # confirm this account. An invitation or a copied URL cannot do so.
        if google_invitation && !user.confirmed? && !user.access_locked?
          user.skip_confirmation!
          user.save!
        end
      end
      unless user.active_for_authentication?
        render json: { message: 'Confirm your account or unlock it using the email we sent you.' }, status: :forbidden
        return
      end

      if creating
        wedding = Wedding.create!(slug: params.require(:slug))
        ActsAsTenant.with_tenant(wedding) { Membership.create!(wedding:, user:, confirmed_at: Time.current) }
      elsif google_invitation
        membership.update!(confirmed_at: Time.current, confirmation_token: nil, confirmation_token_expires_at: nil)
      end
      user.update!(google_subject: payload['sub']) if user.google_subject.nil?
    end

    reset_session # rotate the session before establishing the authenticated identity
    set_current_tenant(wedding)
    sign_in(:user, user)
    render json: user.as_json(only: %i[id email language]), status: :created
  rescue Google::Auth::IDTokens::VerificationError
    head :unauthorized
  rescue Google::Auth::IDTokens::KeySourceError
    render json: { message: 'Google sign-in is temporarily unavailable. Please try again.' }, status: :service_unavailable
  rescue ActiveRecord::RecordNotUnique
    render json: { message: 'This wedding or Google account already exists. Please sign in instead.' }, status: :conflict
  end
end
