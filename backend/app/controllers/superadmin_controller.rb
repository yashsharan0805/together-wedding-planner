# frozen_string_literal: true

class SuperadminController < ActionController::Base # rubocop:disable Rails/ApplicationController
  before_action :set_current_path
  before_action :authenticate_user!
  before_action :ensure_superadmin!

  private

  def ensure_superadmin!
    head :unauthorized unless current_user.superadmin?
  end

  def set_current_path
    Current.request_path = request.path
  end
end
