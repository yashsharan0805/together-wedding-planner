# frozen_string_literal: true

class TasksController < ApplicationController
  before_action -> { doorkeeper_authorize! 'tasks' }, if: :oauth?
  before_action -> { doorkeeper_authorize! 'tasks:write' }, if: :oauth?, only: %i[create update destroy]

  def index
    render json: Task.order(completed_at: :desc, created_at: :asc), only: %i[id title completed_at]
  end

  def create
    Task.create(task_params)

    render json: {}, status: :created
  end

  def update
    Task.find(params[:id]).update!(task_params)

    render json: {}, status: :ok
  end

  def destroy
    Task.find(params[:id]).destroy

    render json: {}, status: :ok
  end

  private

  def task_params
    params.expect(task: %i[title completed_at])
  end
end
