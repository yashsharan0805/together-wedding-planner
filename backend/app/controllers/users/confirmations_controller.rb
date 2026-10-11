# Copyright (C) 2024-2025 LibreWeddingPlanner contributors

# frozen_string_literal: true

module Users
  class ConfirmationsController < Devise::ConfirmationsController
    clear_respond_to
    respond_to :json

    # The user that is visiting the confirmation link may have an active session for another wedding,
    # which is irrelevant for the sake of confirming their new account.
    skip_before_action :validate_access_to_wedding!

    def show
      super do |resource|
        if resource.errors.empty?
          redirect_to root_path(slug: resource.default_wedding.slug)
        else
          render json: {
            message: 'Record invalid',
            errors: resource.errors.full_messages
          }, status: :unprocessable_content
        end
        return
      end
    end
  end
end
