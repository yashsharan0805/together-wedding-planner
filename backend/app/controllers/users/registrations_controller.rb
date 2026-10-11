# Copyright (C) 2024-2025 LibreWeddingPlanner contributors

# frozen_string_literal: true

module Users
  class RegistrationsController < Devise::RegistrationsController
    clear_respond_to
    respond_to :json

    before_action :validate_captcha!, only: :create, unless: -> { ENV['DISABLE_CAPTCHA'] == 'true' }
    after_action :include_error_message

    def create
      wedding = Wedding.create(slug: params[:slug])
      unless wedding.persisted?
        render json: { errors: wedding.errors.full_messages }, status: :unprocessable_content
        return
      end

      ActsAsTenant.with_tenant(wedding) do
        super do |user|
          if user.persisted?
            # The creator of the wedding automatically becomes a confirmed member
            Membership.create!(wedding:, user:, confirmed_at: Time.zone.now)
          else
            wedding.destroy
          end
        end
      end
    end

    private

    def include_error_message
      return if response.status != 422

      parsed_response = JSON.parse(response.body)
      parsed_response['message'] ||= 'Unsuccessful registration'
      response.body = parsed_response.to_json
    end

    def set_tenant
      set_current_tenant(nil)
    end
  end
end
