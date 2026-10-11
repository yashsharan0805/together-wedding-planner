# Copyright (C) 2024-2025 LibreWeddingPlanner contributors

# frozen_string_literal: true

class CaptchaController < ApplicationController
  skip_before_action :authenticate_user!
  skip_before_action :set_tenant
  def create
    if ENV['DISABLE_CAPTCHA'] == 'true'
      render json: {}, status: :no_content
    else
      id = LibreCaptcha.new.id
      render json: {
        id:,
        media_url: media_captcha_index_url(id:)
      }, status: :created
    end
  end
end
