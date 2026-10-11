# frozen_string_literal: true

class BusesController < ApplicationController
  before_action -> { doorkeeper_authorize! 'buses' }, if: :oauth?
  before_action -> { doorkeeper_authorize! 'buses:write' }, if: :oauth?, only: %i[create destroy]
  def index
    render json: Bus.with_number.order(seats: :desc, id: :asc).as_json(only: %i[id seats], methods: :number),
           status: :ok
  end

  def create
    Bus.create!(bus_params)
    render json: {}, status: :created
  end

  def destroy
    Bus.find(params[:id]).destroy!
    render json: {}, status: :ok
  end

  def stats
    query = Buses::StatsQuery.new

    render json: {
      confirmed: query.confirmed,
      potential: query.potential
    }
  end

  private

  def bus_params
    params.expect(bus: :seats)
  end
end
