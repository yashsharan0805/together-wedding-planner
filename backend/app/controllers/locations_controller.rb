# frozen_string_literal: true

class LocationsController < ApplicationController
  before_action -> { doorkeeper_authorize! 'locations' }, if: :oauth?
  before_action -> { doorkeeper_authorize! 'locations:write' }, if: :oauth?, only: %i[create destroy]

  def index
    render json: Location.order(created_at: :desc), only: %i[id label latitude longitude place_id display_name]
  end

  def create
    Location.create!(location_params)

    render json: {}, status: :created
  end

  def destroy
    Location.find(params[:id]).destroy

    render json: {}, status: :ok
  end

  private

  def location_params
    params.expect(location: %i[label latitude longitude place_id display_name])
  end
end
