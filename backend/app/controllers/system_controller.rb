# frozen_string_literal: true

class SystemController < ApplicationController
  skip_before_action :verify_authenticity_token
  skip_before_action :doorkeeper_authorize!, if: -> { Rails.env.development? }
  before_action -> { doorkeeper_authorize! 'system' }, unless: -> { Rails.env.development? }

  private

  def set_tenant
    raise NotImplementedError, 'implement in subclasses'
  end
end
