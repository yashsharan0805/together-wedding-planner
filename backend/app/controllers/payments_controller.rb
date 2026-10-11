# frozen_string_literal: true

class PaymentsController < ApplicationController
  before_action -> { doorkeeper_authorize! 'expenses' }, if: :oauth?
  before_action -> { doorkeeper_authorize! 'expenses:write' }, if: :oauth?, only: %i[create update destroy]

  def create
    Payment.create!(payment_params)
    render json: {}, status: :created
  end

  def update
    Payment.find(params[:id]).update!(payment_params)
    render json: {}, status: :ok
  end

  def destroy
    Payment.find(params[:id]).destroy!
    render json: {}, status: :ok
  end

  private

  def payment_params
    params.expect(payment: %i[title amount expense_id cost_center_id])
  end
end
