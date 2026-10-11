# Copyright (C) 2024-2025 LibreWeddingPlanner contributors

# frozen_string_literal: true

module Users
  class SessionsController < Devise::SessionsController
    clear_respond_to
    respond_to :json

    prepend_before_action :set_tenant, only: %i[destroy create] # rubocop:disable Rails/LexicallyScopedActionFilter

    private

    def set_tenant
      set_current_tenant(Wedding.find_by!(slug: params[:slug]))
    end
  end
end
