# frozen_string_literal: true

class TablesController < ApplicationController
  before_action -> { doorkeeper_authorize! 'simulations' }, if: :oauth?
  before_action -> { doorkeeper_authorize! 'simulations:write' }, if: :oauth?, only: %i[create update]
  def create
    # TODO: Check existing tables to see what size is most suitable or get from user
    capacity = TableType.order(Arel.sql('availability NULLS FIRST')).first.capacity
    tables_arrangement.tables.create!(capacity:)

    render json: {}, status: :ok
  end

  def update
    tables_arrangement.tables.find(params[:id]).update!(params.expect(table: [:name]))

    render json: {}, status: :ok
  end

  private

  def tables_arrangement
    TablesArrangement.find(params[:tables_arrangement_id])
  end
end
