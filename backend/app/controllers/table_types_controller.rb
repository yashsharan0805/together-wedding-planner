# frozen_string_literal: true

class TableTypesController < ApplicationController
  AS_JSON_PARAMS = { only: %i[id availability], methods: :capacity_limits }.freeze

  before_action -> { doorkeeper_authorize! 'simulations' }, if: :oauth?
  before_action -> { doorkeeper_authorize! 'simulations:write' }, if: :oauth?, only: %i[create update destroy]

  def index
    render json: TableType.ordered.map { it.as_json(**AS_JSON_PARAMS) },
           status: :ok
  end

  def create
    table_type = TableType.create!(table_type_params)
    render json: table_type.as_json(**AS_JSON_PARAMS), status: :created
  end

  def update
    table_type = TableType.find(params[:id])
    table_type.update!(table_type_params)
    render json: table_type.as_json(**AS_JSON_PARAMS), status: :ok
  end

  def destroy
    TableType.find(params[:id]).destroy!
    render json: {}, status: :ok
  end

  private

  def table_type_params
    original_params = params.expect(table_type: [:availability, { capacity_limits: %i[min max] }]).to_h

    original_params[:capacity] = original_params[:capacity_limits].values_at(:min, :max).then { Range.new(*it) }

    original_params.delete(:capacity_limits)
    original_params
  end
end
