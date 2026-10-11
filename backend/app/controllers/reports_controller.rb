# frozen_string_literal: true

class ReportsController < ApplicationController
  def show
    doorkeeper_authorize! 'guests' if oauth? # Change me if a report doesn't involve guests

    if report.nil?
      render json: {
        message: 'Unsupported report',
        errors: ["Report #{report_id} not supported"]
      }, status: :not_found and return
    end

    respond_to do |format|
      format.json { render json: report.to_h }
      format.csv { send_data report.to_csv, filename: "#{report_id}.csv" }
    end
  end

  private

  def report_id
    params.require(:id)
  end

  def report
    @report ||= case report_id
                when 'catering'
                  Reports::CateringReport.new(wedding: ActsAsTenant.current_tenant)
                when 'bus_groups'
                  Reports::BusGroupsReport.new(wedding: ActsAsTenant.current_tenant)
                when 'bus_needs_true'
                  Reports::BusNeedsReport.new(wedding: ActsAsTenant.current_tenant, needs_bus: true)
                when 'bus_needs_false'
                  Reports::BusNeedsReport.new(wedding: ActsAsTenant.current_tenant, needs_bus: false)
                end
  end
end
