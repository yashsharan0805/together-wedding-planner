# frozen_string_literal: true

class MenuOptionsController < ApplicationController
  skip_before_action :authenticate_user!, only: :index # For the public website

  def index
    render json: MenuOption.all, only: %i[id name i18n_key]
  end

  def create
    MenuOption.create!(menu_option_params)

    render json: {}, status: :created
  end

  def update
    MenuOption.find(params[:id]).update!(menu_option_params)

    render json: {}, status: :ok
  end

  def destroy
    MenuOption.find(params[:id]).destroy!

    render json: {}, status: :ok
  end

  private

  def menu_option_params
    params.require(:menu_option).permit(:name)
  end
end
