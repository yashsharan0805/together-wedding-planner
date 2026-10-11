# Copyright (C) 2024-2025 LibreWeddingPlanner contributors

# frozen_string_literal: true

class ApplicationController < ActionController::Base
  set_current_tenant_through_filter
  before_action :set_tenant
  before_action :doorkeeper_authorize!, if: :oauth?
  before_action :authenticate_user!, unless: :oauth?
  before_action :set_current_path
  before_action :validate_access_to_wedding!

  after_action :set_csrf_cookie

  skip_before_action :verify_authenticity_token, if: :development_swagger?

  rescue_from ActiveRecord::RecordInvalid do |exception|
    render json: {
      message: 'Record invalid',
      errors: exception.record.errors.full_messages
    }, status: :bad_request
  end

  rescue_from ActionController::ParameterMissing do |exception|
    render json: {
      message: 'Parameter missing',
      errors: [exception.message]
    }, status: :bad_request
  end

  rescue_from ActiveRecord::RecordNotFound do |exception|
    render json: {
      message: 'Record not found',
      errors: [exception.message]
    }, status: :not_found
  end

  rescue_from ActiveRecord::RecordNotDestroyed do |exception|
    render json: {
      message: 'Cannot destroy record',
      errors: [exception.message]
    }, status: :internal_server_error
  end

  private

  def validate_access_to_wedding!
    return if current_user.nil? || ActsAsTenant.current_tenant.nil?
    return if Membership.exists?(user: current_user, wedding: ActsAsTenant.current_tenant, confirmed_at: ..Time.zone.now)

    render json: {
      message: 'Current user is not a member of this wedding',
      errors: []
    }, status: :forbidden
  end

  def set_current_path
    Current.request_path = request.path
  end

  def validate_captcha!
    return if LibreCaptcha.new.valid?(id: captcha_params[:id], answer: captcha_params[:answer])

    render json: { error: 'Incorrect CAPTCHA solution' }, status: :unprocessable_content
  end

  def captcha_params
    params.expect(captcha: %i[id answer])
  end

  def default_url_options(options = {})
    options.merge(path_params: { slug: ActsAsTenant.current_tenant&.slug })
  end

  def set_tenant
    set_current_tenant(Wedding.find_by!(slug: params[:slug]))
  end

  def current_user
    oauth? ? doorkeeper_token.application.owner : super
  end

  def development_swagger?
    Rails.env.test? ||
      (Rails.env.development? && request.headers['referer']&.include?('/api-docs/index.html'))
  end

  def set_csrf_cookie
    cookies['csrf-token'] = {
      value: form_authenticity_token,
      secure: Rails.env.production?,
      same_site: :strict
    }
  end

  def oauth?
    request.headers['authorization']&.start_with?('Bearer')
  end
end
