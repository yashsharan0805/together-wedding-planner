# frozen_string_literal: true

class UsersController < ApplicationController
  skip_before_action :authenticate_user!

  def update
    if params[:id] == current_user.id || params[:id] == 'current'
      user.update!(user_params)
      render json: {}, status: :ok
    else
      render json: {}, status: :forbidden
    end
  end

  def whoami
    if current_user
      render json: current_user.as_json(only: %i[id language email]).merge(slug: ActsAsTenant.current_tenant.slug),
             status: :ok
    else
      render json: {
        message: 'Session not started',
        errors: ['Sign in to use the application']
      }, status: :unauthorized
    end
  end

  private

  def user
    if params[:id] == 'current'
      current_user
    else
      User.find(params[:id])
    end
  end

  def user_params
    params.require(:user).permit(:language)
  end
end
