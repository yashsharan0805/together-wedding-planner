# Copyright (C) 2024-2025 LibreWeddingPlanner contributors

# frozen_string_literal: true

class TokensController < ApplicationController
  skip_before_action :authenticate_user!
  skip_before_action :set_tenant

  def show
    head :ok
  end
end
