# frozen_string_literal: true

class CostCentersController < ApplicationController
  before_action -> { doorkeeper_authorize! 'expenses' }, if: :oauth?
  before_action -> { doorkeeper_authorize! 'expenses:write' }, if: :oauth?, only: %i[create update destroy]

  def index
    render json: CostCenter.all.as_json(only: %i[id name])
  end

  def create
    CostCenter.create!(cost_center_params)

    render json: {}, status: :created
  end

  def update
    CostCenter.find(params[:id]).update!(cost_center_params)

    render json: {}, status: :ok
  end

  def destroy
    CostCenter.find(params[:id]).destroy!

    render json: {}, status: :ok
  end

  def stats
    render json: CostCenters::StatsQuery.new.call, status: :ok
  end

  private

  def cost_center_params
    params.expect(cost_center: [:name])
  end
end
