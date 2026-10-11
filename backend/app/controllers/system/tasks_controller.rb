# frozen_string_literal: true

module System
  class TasksController < SystemController
    def update
      if (latest_version = simulation.wedding.simulation_version) > params['version']
        render json: {
          message: "Solution sent for version #{params['version']} but current version is #{latest_version}"
        }, status: :unprocessable_content
        return
      end

      simulation.with_lock do
        simulation.engine_stats.delete_all if params[:progress].to_f.zero?
        SolutionPersister.new(simulation, params[:solution]).call if params[:solution]
        simulation.update!(
          {
            status: params[:status],
            progress: params[:progress],
            optimized_version: params[:version]
          }.compact
        )
      end
      render json: {}, status: :ok
    end

    def create_stats
      simulation.engine_stats.create!(
        params.expect(
          stats: %i[evaluation_count iteration
                    real_time system_time total_time user_time]
        )
      )
      render json: {}, status: :created
    end

    private

    def set_tenant
      set_current_tenant(simulation.wedding)
    end

    def simulation
      @simulation ||= TablesArrangement.find(params.require(:id))
    end
  end
end
