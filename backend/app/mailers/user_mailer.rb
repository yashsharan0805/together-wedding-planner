# Copyright (C) 2024-2025 LibreWeddingPlanner contributors

# frozen_string_literal: true

require 'rubygems/package'

class UserMailer < ApplicationMailer
  def membership_invitation_email
    @membership = Membership.find(params[:id])

    mail(to: @membership.user.email, subject: I18n.t('user_mailer.membership_invitation.subject'))
  end
end
