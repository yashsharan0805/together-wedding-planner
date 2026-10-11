# Copyright (C) 2024-2025 LibreWeddingPlanner contributors

# frozen_string_literal: true

class TablesArrangementsController < ApplicationController
  before_action -> { doorkeeper_authorize! 'simulations' }, if: :oauth?
  before_action lambda {
    doorkeeper_authorize! 'simulations:write'
  }, if: :oauth?, only: %i[move pin optimize reset]

  before_action :validate_too_many_queued_jobs!, only: %i[optimize]

  MAX_QUEUED_JOBS = 5
  private_constant :MAX_QUEUED_JOBS

  def index
    seats_query = Seat
                  .distinct
                  .group(:tables_arrangement_id)
                  .select(:tables_arrangement_id)
                  .select('count(DISTINCT table_id) AS total_table_count')

    query = TablesArrangement
            .order(system: :desc)
            .order(discomfort: :asc)
            .select(:id, :discomfort, :status, :progress, :system)
            .joins("LEFT JOIN (#{seats_query.to_sql}) seats_count ON seats_count.tables_arrangement_id = tables_arrangements.id")
            .select('COALESCE(seats_count.total_table_count, 0) AS total_table_count')
            .limit((params[:limit].presence&.to_i || 20).clamp(1..20))

    query = query.where(status: params[:status]) if params[:status].present?

    render json: query.as_json(only: %i[id discomfort status progress total_table_count system])
  end

  def show
    tables_arrangement = TablesArrangement.includes(tables: [:guests, { seats: { guest: [:group] } }]).find(params[:id])
    tables = tables_arrangement.tables.map do |table|
      {
        id: table.id,
        number: table.number,
        name: table.name,
        guests: guests_in_table(table),
        discomfort: discomfort(
          guests: table.guests,
          min_per_table: table.capacity.min,
          max_per_table: table.capacity.max
        ),
        capacity_limits: { min: table.capacity.min, max: table.capacity.max }
      }
    end

    evaluation_count, time = tables_arrangement.engine_stats.pick('sum(evaluation_count)', 'sum(real_time)')

    render json: {
      id: tables_arrangement.id,
      status: tables_arrangement.status,
      progress: tables_arrangement.progress,
      system: tables_arrangement.system,
      tables:,
      stats: {
        evaluation_count: evaluation_count.to_i,
        time:
      }
    }
  end

  def move
    ActiveRecord::Base.transaction do
      tables_arrangement.seats.find_by!(guest:).update!(table:)
      tables_arrangement.reload.recalculate_discomfort!
    end

    render json: {}, status: :ok
  end

  def pin
    tables_arrangement.seats.find_by!(guest:, table:).update!(pinned: params[:pinned])

    render json: {}, status: :ok
  end

  def optimize
    ActiveRecord::Base.transaction do
      tables_arrangement.update!(status: :not_started)
      current_tenant.needs_optimization!
    end

    render json: {}, status: :ok
  end

  def reset
    tables_arrangement = TablesArrangement.find(params[:id])
    tables_arrangement.reset!
    current_tenant.needs_optimization!
    render json: {}, status: :ok
  end

  private

  def guests_in_table(table)
    table.seats
         .sort_by { [it.guest.invitation_id || '', it.guest.invitation_order] }
         .map { it.guest.as_json(only: %i[id name], methods: :color).merge(pinned: it.pinned) }
  end

  def validate_too_many_queued_jobs!
    queued_count = TablesArrangement.where(status: %i[in_progress not_started]).count

    render json: { error: 'queue_limit_reached' }, status: :too_many_requests if queued_count >= MAX_QUEUED_JOBS
  end

  def tables_arrangement
    @tables_arrangement ||= TablesArrangement.find(params[:id])
  end

  def guest
    @guest ||= tables_arrangement.guests.find(params[:guest_id])
  end

  def table
    @table ||= tables_arrangement.tables.find(params[:table_id])
  end

  def discomfort(guests:, min_per_table:, max_per_table:)
    table = Tables::Table.new(guests)

    table.min_per_table = min_per_table
    table.max_per_table = max_per_table
    calculator = Tables::DiscomfortCalculator.new(table:, hierarchy:)
    {
      discomfort: calculator.calculate,
      breakdown: calculator.breakdown
    }
  end

  def hierarchy
    @hierarchy ||= AffinityGroupsHierarchy.new
  end
end
