# frozen_string_literal: true

class CreateMembershipUseCase < BaseUseCase
  TOKEN_DURATION = 1.week.freeze
  private_constant :TOKEN_DURATION

  private attr_reader :email
  def initialize(email:)
    super()
    @email = email.to_s.strip.downcase
  end

  private

  def private_call
    user = User.find_or_create_by(email:) do |new_user|
      new_user.password = new_user.password_confirmation = SecureRandom.alphanumeric(60)
      # Google proves ownership when an invited person signs in. Do not mark
      # the account confirmed simply because another member invited it.
      new_user.skip_confirmation_notification! if ENV['TOGETHER_GOOGLE_INVITES'] == 'true'
    end

    unless user.valid?
      @errors = user.errors.full_messages
      return false
    end

    membership = Membership.create(
      user:,
      wedding:,
      confirmed_at: nil,
      confirmation_token: SecureRandom.alphanumeric(60),
      confirmation_token_expires_at: TOKEN_DURATION.from_now
    )

    unless membership.persisted?
      @errors = membership.errors.full_messages
      return false
    end

    UserMailer.with(id: membership.id).membership_invitation_email.deliver_now unless ENV['TOGETHER_GOOGLE_INVITES'] == 'true'

    true
  end
end
