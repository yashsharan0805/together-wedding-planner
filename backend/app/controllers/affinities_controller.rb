# Copyright (C) 2024-2025 LibreWeddingPlanner contributors

# frozen_string_literal: true

class AffinitiesController < ApplicationController
  before_action :set_group, except: :reset

  before_action -> { doorkeeper_authorize! 'guests' }, if: :oauth?
  before_action -> { doorkeeper_authorize! 'guests:write' }, if: :oauth?, only: %i[bulk_update reset]

  def index
    overridden = @group.affinities.to_h do |affinity|
      [affinity.another_group(@group).id, affinity.discomfort]
    end

    for_each_group do |group_id|
      overridden[group_id] || GroupAffinity::NEUTRAL
    end
  end

  def bulk_update
    affinities = params.expect(affinities: [%i[group_id affinity]]).map(&:to_h).map do |affinity|
      {
        group_a_id: @group.id,
        group_b_id: affinity[:group_id],
        discomfort: GroupAffinity::MAX_DISCOMFORT - affinity[:affinity]
      }
    end

    GroupAffinity.upsert_all(affinities, unique_by: :uindex_group_pair)
    ActsAsTenant.current_tenant.needs_optimization!

    render json: {}, status: :ok
  rescue ActiveRecord::InvalidForeignKey
    render json: { error: 'At least one of the group IDs provided does not exist.' }, status: :bad_request
  rescue ActiveRecord::StatementInvalid
    render json: { error: 'Invalid group ID or discomfort provided.' }, status: :bad_request
  end

  def default
    hierarchy = AffinityGroupsHierarchy.new

    for_each_group do |group_id|
      hierarchy.default_discomfort(@group.id, group_id).to_f
    end
  end

  def reset
    hierarchy = AffinityGroupsHierarchy.new

    affinities = Group.pluck(:id).combination(2).map do |(group_a_id, group_b_id)|
      {
        group_a_id:,
        group_b_id:,
        discomfort: hierarchy.default_discomfort(group_a_id, group_b_id).to_f
      }
    end

    GroupAffinity.upsert_all(affinities, unique_by: :uindex_group_pair)
    ActsAsTenant.current_tenant.needs_optimization!

    render json: {}, status: :ok
  end

  private

  def for_each_group
    Group.where.not(id: @group.id)
         .pluck(:id)
         .index_with { |group_id| GroupAffinity::MAX_DISCOMFORT - yield(group_id) }
         .then { |affinities| render json: affinities }
  end

  def set_group
    @group = Group.find(params[:group_id])
  end
end
