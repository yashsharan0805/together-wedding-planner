# Copyright (C) 2024-2025 LibreWeddingPlanner contributors

# frozen_string_literal: true

class GroupsController < ApplicationController
  before_action -> { doorkeeper_authorize! 'guests' }, if: :oauth?
  before_action -> { doorkeeper_authorize! 'guests:write' }, if: :oauth?, only: %i[create update destroy]

  def index
    query_result = Groups::SummaryQuery.new.call.as_json.map(&:deep_symbolize_keys).map do |group|
      {
        id: group[:id],
        name: group[:name],
        icon: group[:icon],
        color: group[:color],
        parent_id: group[:parent_id],
        attendance: group.slice(:total, :considered, :invited, :confirmed, :declined, :tentative)
      }
    end

    render json: query_result
  end

  def create
    group = Group.create!(**group_params, parent:)
    render json: group.as_json(only: %i[id name icon color parent_id]), status: :created
  end

  def update
    group = Group.find(params[:id])
    group.update!(**group_params, parent:)
    render json: group.as_json(only: %i[id name icon color parent_id]), status: :ok
  end

  def destroy
    Group.find(params[:id]).destroy!
    render json: {}, status: :ok
  end

  private

  def parent
    params[:group][:parent_id].present? ? Group.find(params[:group][:parent_id]) : nil
  end

  def group_params
    params.expect(group: %i[name icon color])
  end
end
