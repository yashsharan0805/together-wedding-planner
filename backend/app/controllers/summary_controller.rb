# Copyright (C) 2024-2025 LibreWeddingPlanner contributors

# frozen_string_literal: true

class SummaryController < ApplicationController
  before_action -> { doorkeeper_authorize! 'guests' }, if: :oauth?
  before_action -> { doorkeeper_authorize! 'expenses' }, if: :oauth?

  def index
    render json: {
      expenses:,
      guests:
    }
  end

  private

  def guests
    guest_summary = Guest.group(:status).count

    {
      total: guest_summary.except('considered').values.sum,
      confirmed: guest_summary['confirmed'].to_i,
      declined: guest_summary['declined'].to_i,
      tentative: guest_summary['tentative'].to_i,
      invited: guest_summary['invited'].to_i
    }
  end

  def expenses
    expense_summary = Expenses::TotalQuery.new(wedding: ActsAsTenant.current_tenant).call

    {
      projected: {
        total: expense_summary['total_projected'],
        guests: expense_summary['projected_guests']
      },
      confirmed: {
        total: expense_summary['total_confirmed'],
        guests: expense_summary['confirmed_guests']
      },
      status: {
        paid: expense_summary['total_paid']
      }
    }
  end
end
