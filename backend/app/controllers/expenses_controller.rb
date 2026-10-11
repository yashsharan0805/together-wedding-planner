# Copyright (C) 2024-2025 LibreWeddingPlanner contributors

# frozen_string_literal: true

class ExpensesController < ApplicationController
  before_action -> { doorkeeper_authorize! 'expenses' }, if: :oauth?
  before_action -> { doorkeeper_authorize! 'expenses:write' }, if: :oauth?, only: %i[create update destroy]

  def summary
    render json: Expenses::TotalQuery.new.call
  end

  def index
    render json: Expense.includes(:payments)
                        .order(pricing_type: :asc, amount: :desc)
                        .as_json(
                          only: %i[id name amount pricing_type],
                          include: { payments: { only: %i[id title amount cost_center_id] } }
                        )
  end

  def create
    Expense.create!(expense_params)
    render json: {}, status: :created
  end

  def update
    Expense.find(params[:id]).update!(expense_params)
    render json: {}, status: :ok
  end

  def destroy
    Expense.find(params[:id]).destroy!
    render json: {}, status: :ok
  end

  private

  def expense_params
    params.expect(expense: %i[name amount pricing_type])
  end
end
