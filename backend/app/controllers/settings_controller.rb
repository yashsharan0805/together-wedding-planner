# frozen_string_literal: true

class SettingsController < ApplicationController
  include ActiveStorage::SetCurrent

  skip_before_action :authenticate_user!, only: [
    :show, # Anonymous access to RSVP page
    :confirm_wedding_deletion # Includes a short-lived deletion_token to verify origin
  ]
  skip_before_action :verify_authenticity_token, only: :set_invitation_background

  before_action -> { doorkeeper_authorize! 'settings' }, if: :oauth?
  before_action lambda {
    doorkeeper_authorize! 'settings:write'
  }, if: :oauth?, only: %i[update set_invitation_background request_wedding_deletion]

  ALLOWED_WITHOUT_AUTH = %w[display_menu_choices bus_management].freeze
  ALLOWED_SETTINGS = (%w[date invitation_config] + ALLOWED_WITHOUT_AUTH).freeze

  def show
    raise ActionController::ParameterMissing, 'ids' unless params.key?(:ids)

    serializer_options = { only: allowed_settings }

    if allowed_settings.include?('invitation_config')
      serializer_options[:include] = {
        invitation_config: {
          only: %i[qr_position qr_size_px qr_color qr_fill_color
                   text_position text_font_family text_color text_font_size text_font_weight text_align],
          methods: [:fonts_available],
          include: { background: { only: [], methods: %i[url metadata] } }
        }
      }
    end

    render json: settings.as_json(serializer_options), status: :ok
  end

  def update
    raise ActionController::ParameterMissing, 'settings' if settings_params.keys.empty?

    ActiveRecord::Base.transaction do
      settings.update!(settings_params)
    end

    if settings.errors.any?
      render json: {
        errors: settings.errors
      }, status: :bad_request
    else
      render json: {}, status: :ok
    end
  end

  def set_invitation_background
    if params[:invitation_background].blank?
      render json: { message: 'Background image is required' }, status: :bad_request
      return
    end

    result = settings.invitation_config.update!(background: params[:invitation_background])

    if result
      render json: { url: settings.invitation_config.background.url }, status: :ok
    else
      # TODO

      render json: result.errors, status: :bad_request
    end
  end

  def fonts
    render json: { fonts: FONTS_AVAILABLE }
  end

  def request_wedding_deletion
    ActsAsTenant.current_tenant.generate_deletion_token!
    AdminMailer.with(wedding_id: ActsAsTenant.current_tenant.id).wedding_deletion_request_email.deliver_later

    render json: {}, status: :ok
  end

  def confirm_wedding_deletion
    wedding = ActsAsTenant.current_tenant

    if wedding.deletion_token.present? &&
       wedding.deletion_token_expires_at.future? &&
       wedding.deletion_token == params[:deletion_token]

      wedding.destroy

      redirect_to('/system/successful-website-deletion')
    else
      redirect_to('/system/unsuccessful-website-deletion')
    end
  end

  private

  def settings
    @settings ||= ActsAsTenant.current_tenant.settings
  end

  def allowed_settings
    settings = Array.wrap(params[:ids]) & ALLOWED_SETTINGS
    settings &= ALLOWED_WITHOUT_AUTH unless current_user
    settings
  end

  def settings_params
    params.expect(settings: [
                    :date,
                    :display_menu_choices,
                    :bus_management,
                    { invitation_config_attributes: [
                      :qr_color, :qr_fill_color, :qr_size_px,
                      :text_color, :text_align, :text_font_family, :text_font_size, :text_font_weight,
                      { qr_position: %i[x y],
                        text_position: %i[x y] }
                    ] }
                  ])
  end
end
