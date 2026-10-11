# Copyright (C) 2024-2025 LibreWeddingPlanner contributors

# frozen_string_literal: true

class WebsitesController < ApplicationController
  before_action -> { doorkeeper_authorize! 'website' }, if: :oauth?
  before_action -> { doorkeeper_authorize! 'website:write' }, if: :oauth?, only: %i[update]

  skip_before_action :authenticate_user!, only: :show

  def show
    render json: current_tenant.website.as_json(only: %i[content domain pages version]) || {}, status: :ok
  end

  def update
    ActiveRecord::Base.transaction do
      website = current_tenant.website || current_tenant.create_website
      website.update!(website_params)
      render json: {}, status: :ok
    end
  end

  def validate_dns
    render json: {}, status: :unprocessable_content if current_tenant.website.domain.blank?

    DNSValidator.new(current_tenant.website.domain).call
    render json: {}, status: :ok
  rescue DNSValidator::MissingRecordError => e
    render json: {
      message: 'Incorrect DNS configuration',
      errors: [e.message]
    }, status: :ok
  end

  private

  def website_params
    params.expect(website: [:content, :domain, :version,
                            { pages: [%i[slug title subtitle content title_font_family]] }])
  end
end
