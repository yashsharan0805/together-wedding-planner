# frozen_string_literal: true

class EngineController < ApplicationController
  before_action -> { doorkeeper_authorize! 'engine' }, if: :oauth?
  before_action -> { doorkeeper_authorize! 'engine:write' }, if: :oauth?, only: %i[heartbeat]

  def heartbeat
    render json: {}, status: :forbidden and return unless oauth?

    key = "engine/heartbeat/#{doorkeeper_token.application_id}"
    WeddingPlanner.redis.set(key, Time.zone.now, ex: 1.hour.in_seconds)

    render json: {}, stauts: :ok
  end
end
