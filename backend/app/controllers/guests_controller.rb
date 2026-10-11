# Copyright (C) 2024-2025 LibreWeddingPlanner contributors

# frozen_string_literal: true

require 'csv'

class GuestsController < ApplicationController
  UUID_REGEX = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/
  GUEST_PARAMS = {
    only: %i[id name status menu_restrictions special_requests],
    methods: [:menu_choice],
    include: { group: { only: %i[id name] } }
  }.freeze
  ANONYMOUS_EDITS_ALLOWED_PARAMS = %i[status menu_restrictions needs_bus special_requests].freeze
  AUTHENTICATED_EDITS_ALLOWED_PARAMS = (ANONYMOUS_EDITS_ALLOWED_PARAMS + %i[name group_id]).freeze

  private_constant :GUEST_PARAMS, :ANONYMOUS_EDITS_ALLOWED_PARAMS, :AUTHENTICATED_EDITS_ALLOWED_PARAMS

  # Guests can be updated by anonymous users to fill the RSVP form
  skip_before_action :authenticate_user!, only: :update

  before_action -> { doorkeeper_authorize! 'guests' }, if: :oauth?
  before_action -> { doorkeeper_authorize! 'guests:write' }, if: :oauth?, only: %i[create update destroy]

  def index
    respond_to do |format|
      format.json do
        guests = Guest.includes(:group, :menu_option)
                      .left_joins(:group)
                      .order('groups.name' => :asc, invitation_id: :asc, name: :asc)
        render json: guests.as_json(GUEST_PARAMS)
      end
      format.csv do
        file = Guests::Exporter.new(wedding: ActsAsTenant.current_tenant).call
        send_data file, filename: 'guest-export.csv'
      end
    end
  end

  def create
    guest = Guest.create!(guest_params)
    render json: guest.as_json(GUEST_PARAMS), status: :created
  end

  def update
    guest = Guest.find(params[:id])

    if menu_option && params[:guest].empty?
      guest.update!(menu_option:)
    elsif menu_option
      guest.update!(menu_option:, **guest_params)
    else
      guest.update!(guest_params)
    end

    if !user_signed_in? && guest.saved_change_to_status?
      AdminMailer.with(guest_id: guest.id).attendance_change_email.deliver_later
    end

    render json: guest.as_json(GUEST_PARAMS), status: :ok
  end

  def destroy
    Guest.find(params[:id]).destroy!
    render json: {}, status: :ok
  end

  def import
    ActiveRecord::Base.transaction do
      ActsAsTenant.current_tenant.empty! if params.require(:delete_existing_records)

      incoming_group_names = params.require(:records).pluck(:group_name).compact_blank.uniq
      new_group_names = incoming_group_names - ActsAsTenant.current_tenant.groups.pluck(:name)
      new_group_names.map { { name: it } }.then { ActsAsTenant.current_tenant.groups.insert_all!(it) }
      name_id_mapping = ActsAsTenant.current_tenant.groups.where(name: incoming_group_names).pluck(:name, :id).to_h

      incoming_menu_options = params.require(:records).pluck(:menu_choice).compact_blank.uniq
      new_menu_option_names = incoming_menu_options - ActsAsTenant.current_tenant.menu_options.pluck(:name)
      new_menu_option_names.map { { name: it } }.then { ActsAsTenant.current_tenant.menu_options.insert_all!(it) }
      menu_option_mapping = MenuOption.where(name: incoming_menu_options).pluck(:name, :id).to_h

      default = Guest.new

      guests_to_insert = params.require(:records).map do |row|
        {
          name: row[:name]&.strip,
          group_id: name_id_mapping[row[:group_name]],
          status: Guest.statuses.keys.include?(row[:status]) ? row[:status] : default.status,
          menu_option_id: menu_option_mapping[row[:menu_choice]],
          menu_restrictions: row[:menu_restrictions].presence&.strip,
          needs_bus: row[:needs_bus].presence || default.needs_bus
        }
      end

      ActsAsTenant.current_tenant.guests.insert_all!(guests_to_insert)
    end

    render json: {}, status: :created
  end

  private

  def menu_option
    @menu_option ||= if params[:guest][:menu_choice].present?
                       choice = params[:guest].delete(:menu_choice)

                       if UUID_REGEX.match?(choice)
                         MenuOption.find(choice)
                       else
                         MenuOption.find_by!(i18n_key: choice)
                       end
                     end
  end

  def guest_params
    params.expect(guest: user_signed_in? ? AUTHENTICATED_EDITS_ALLOWED_PARAMS : ANONYMOUS_EDITS_ALLOWED_PARAMS)
  end
end
