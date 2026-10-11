# Copyright (C) 2024-2025 LibreWeddingPlanner contributors

# frozen_string_literal: true

class InvitationsController < ApplicationController
  include ActiveStorage::SetCurrent

  skip_before_action :authenticate_user!, only: :show

  before_action -> { doorkeeper_authorize! 'guests' }, if: :oauth?
  before_action -> { doorkeeper_authorize! 'guests:write' }, if: :oauth?, only: %i[create update destroy]

  def index
    @invitations = Invitation.includes(%i[wedding guests]).order(:id).all
    respond_to do |format|
      format.json do
        render json: @invitations.as_json(
          only: %i[id name],
          methods: :url,
          include: { guests: { only: %i[id name] } }
        )
      end
      format.pdf do
        pdf_html = ActionController::Base.new.render_to_string(
          template: 'invitations/sheet',
          layout: 'pdf',
          locals: {
            invitations: @invitations,
            invitation_config: Settings.first.invitation_config
          }
        )
        pdf = WickedPdf.new.pdf_from_string(pdf_html)
        send_data pdf, filename: "invitations_#{Time.current.strftime('%Y%m%d_%H%M%S')}.pdf"
      end
    end
  end

  def email
    AdminMailer.with(wedding_id: ActsAsTenant.current_tenant.id).invitations_pdf_email.deliver_later

    head :ok
  end

  def sheet; end

  def show
    invitation = Invitation.includes(guests: :menu_option).find(params[:id])

    guest_attributes = %i[id name status menu_restrictions special_requests]
    guest_attributes << :needs_bus if ActsAsTenant.current_tenant.settings.bus_management

    if invitation
      render json: invitation, only: :id,
             include: { guests: { only: guest_attributes, methods: [:menu_choice] } }, status: :ok
    else
      render json: { error: 'Invitation not found' }, status: :not_found
    end
  end

  def create
    invitation = Invitation.create

    if invitation.persisted?
      render json: invitation, only: :id, status: :created
    else
      render json: { errors: invitation.errors.full_messages }, status: :unprocessable_content
    end
  end

  def update
    invitation = Invitation.find(params[:id])

    guest_ids = params.dig(:invitation, :guest_ids)
    guest_ids &= ActsAsTenant.current_tenant.guests.where(id: guest_ids).pluck(:id) # Ignore any unknown guest ID

    ActiveRecord::Base.transaction do
      guest_ids
        .each_with_index
        # Since Postgres will try the insert first, and only update on conflict, we need to provide all
        # columns that are NOT NULL. Otherwise, the insertion attempt fails, and it doesn't even fall back
        # to doing the update.
        .map { |id, i| { id: id, invitation_id: invitation.id, invitation_order: i, name: 'Foo' } }
        .then { Guest.upsert_all(it, unique_by: :id, update_only: %i[invitation_id invitation_order]) }

      invitation.update!(name: params.dig(:invitation, :name)) if params[:invitation].key?(:name)
      ActsAsTenant.current_tenant.needs_optimization!
    end

    render json: invitation, only: :id, include: { guests: { only: %i[id name] } }, status: :ok
  end

  def destroy
    invitation = Invitation.find(params[:id])

    if invitation.destroy
      ActsAsTenant.current_tenant.needs_optimization!
      head :no_content
    else
      render json: { errors: invitation.errors.full_messages }, status: :unprocessable_content
    end
  end

  def envelopes_document
    pdf_html = ActionController::Base.new.render_to_string(
      template: 'invitations/envelopes_document',
      layout: 'pdf',
      locals: { invitations: Invitation.includes(:guests) }
    )
    pdf = WickedPdf.new.pdf_from_string(pdf_html)
    send_data pdf, filename: "envelopes_#{Time.current.strftime('%Y%m%d_%H%M%S')}.pdf"
  end
end
